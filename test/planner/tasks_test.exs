defmodule Planner.TasksTest do
  use Planner.DataCase

  alias Ecto.Adapters.SQL
  alias Ecto.Adapters.SQL.Sandbox
  alias Planner.Labels
  alias Planner.Labels.Label
  alias Planner.Tasks
  alias Planner.Tasks.DailyPlan
  alias Planner.Tasks.Task
  alias Planner.Tasks.TaskLabel
  alias Planner.UserTransaction

  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
  import Planner.TasksFixtures

  setup do
    %{user: user_fixture()}
  end

  test "completing one of three selected tasks does not make room for a fourth", %{user: user} do
    day = ~D[2026-10-01]
    label = label_fixture(user)
    tasks = for _ <- 1..4, do: task_fixture(user, %{label_ids: [label.id]})
    for task <- Enum.take(tasks, 3), do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    [first, middle, third, fourth] = tasks
    assert {:ok, completed} = Tasks.complete_task(user, Integer.to_string(middle.id), day)
    assert completed.id == middle.id
    assert completed.title == middle.title
    assert completed.completed_on == day
    assert is_nil(completed.position)
    assert Repo.preload(completed, :labels).labels == [label]
    assert {:error, :quota_exhausted} = Tasks.select_today(user, fourth.id, day)

    assert {:ok, %{used_choices: 3, today: today, backlog: [remaining], retry: []}} =
             Tasks.snapshot(user, day)

    assert Enum.map(today, &{&1.id, &1.position}) == [{first.id, 1}, {third.id, 2}]
    assert remaining.id == fourth.id
    assert {:ok, ^completed} = Tasks.complete_task(user, middle.id, day)
    assert {:ok, ^completed} = Tasks.complete_task(user, middle.id, Date.add(day, 1))
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: day).used_choices == 3
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: Date.add(day, 1)).used_choices == 0
  end

  test "complete_task rejects backlog, expired, foreign and invalid IDs without spending", %{
    user: user
  } do
    day = ~D[2026-10-01]
    backlog = task_fixture(user)
    expired = task_fixture(user)
    foreign = task_fixture(user_fixture()) |> schedule(day, 1)
    assert {:ok, selected} = Tasks.select_today(user, expired.id, Date.add(day, -1))

    for id <- [nil, "bad-id", -1, foreign.id] do
      assert {:error, :not_found} = Tasks.complete_task(user, id, day)
    end

    for id <- [backlog.id, expired.id] do
      assert {:error, :invalid_state} = Tasks.complete_task(user, id, day)
    end

    assert Repo.get!(Task, backlog.id) == backlog
    assert Repo.get!(Task, expired.id) == selected
    assert Repo.get!(Task, foreign.id) == foreign
    assert Repo.get_by(DailyPlan, user_id: user.id, day: day) == nil
    assert {:ok, %{used_choices: 0, retry: [retry]}} = Tasks.snapshot(user, day)
    assert retry.id == expired.id
    assert {:error, :invalid_state} = Tasks.complete_task(user, retry.id, day)
  end

  test "complete_task uses the server day and empties a single-task plan", %{user: user} do
    task = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, task.id)
    before = Date.utc_today()
    assert {:ok, completed} = Tasks.complete_task(user, task.id)
    assert completed.completed_on in [before, Date.utc_today()]
    assert {:ok, %{used_choices: 1, today: []}} = Tasks.snapshot(user)
  end

  test "completion rolls back when compacting a remaining position fails", %{user: user} do
    day = ~D[2026-10-01]
    first = task_fixture(user)
    second = task_fixture(user)
    for task <- [first, second], do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, original} = Tasks.snapshot(user, day)

    SQL.query!(
      Repo,
      "ALTER TABLE tasks ADD CONSTRAINT reject_test_completion_order CHECK (id <> #{second.id} OR position <> 1) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn -> Tasks.complete_task(user, first.id, day) end
    assert {:ok, ^original} = Tasks.snapshot(user, day)
    assert is_nil(Repo.get!(Task, first.id).completed_on)
  end

  test "concurrent completions preserve one result and consumption" do
    with_committed_user(fn user ->
      day = ~D[2026-10-01]
      task = task_fixture(user)
      assert {:ok, _} = Tasks.select_today(user, task.id, day)
      command = fn -> Tasks.complete_task(user, task.id, day) end
      assert [{:ok, first}, {:ok, second}] = race_planning_commands(user, day, [command, command])
      assert first == second
      assert first.completed_on == day

      assert {:ok, %{used_choices: 1, today: [], backlog: [], retry: []}} =
               Tasks.snapshot(user, day)
    end)
  end

  test "completion racing with return has exactly one consistent winner" do
    with_committed_user(fn user ->
      day = ~D[2026-10-01]
      task = task_fixture(user)
      assert {:ok, _} = Tasks.select_today(user, task.id, day)

      results =
        race_planning_commands(user, day, [
          fn -> Tasks.complete_task(user, task.id, day) end,
          fn -> Tasks.return_to_backlog(user, task.id, day) end
        ])

      assert Enum.count(results, &match?({:ok, %Task{}}, &1)) == 1
      assert Enum.count(results, &(&1 == {:error, :invalid_state})) == 1
      assert {:ok, snapshot} = Tasks.snapshot(user, day)
      assert snapshot.today == []
      assert snapshot.retry == []
      persisted = Repo.get!(Task, task.id)

      case persisted.completed_on do
        ^day ->
          assert snapshot.used_choices == 1
          assert snapshot.backlog == []

        nil ->
          assert snapshot.used_choices == 0
          assert persisted.kind == :backlog
          assert Enum.map(snapshot.backlog, & &1.id) == [task.id]
      end
    end)
  end

  test "reorder_today persists an exact permutation without changing quota", %{user: user} do
    day = ~D[2026-10-01]
    tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    ids = tasks |> Enum.reverse() |> Enum.map(& &1.id)
    assert {:ok, reordered} = Tasks.reorder_today(user, Enum.map(ids, &Integer.to_string/1), day)
    assert Enum.map(reordered, & &1.id) == ids
    assert Enum.map(reordered, & &1.position) == [1, 2, 3]
    assert {:ok, repeated} = Tasks.reorder_today(user, ids, day)
    assert Enum.map(repeated, &{&1.id, &1.position}) == Enum.map(reordered, &{&1.id, &1.position})
    assert {:ok, %{today: today, used_choices: 3}} = Tasks.snapshot(user, day)
    assert Enum.map(today, & &1.id) == ids
  end

  test "reorder_today rejects nonpermutations without changing state", %{user: user} do
    day = ~D[2026-10-01]
    first = task_fixture(user)
    second = task_fixture(user)
    backlog = task_fixture(user)
    foreign = task_fixture(user_fixture()) |> schedule(day, 1)
    completed = task_fixture(user) |> schedule(day, 3)
    completed |> change(completed_on: day) |> Repo.update!()
    for task <- [first, second], do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, original} = Tasks.snapshot(user, day)

    for ids <- [
          [],
          [first.id],
          [first.id, first.id],
          [first.id, foreign.id],
          [first.id, -1],
          [first.id, backlog.id],
          [first.id, completed.id],
          [first.id, "bad-id"],
          [nil, second.id],
          "bad-list",
          nil
        ] do
      assert {:error, :invalid_order} = Tasks.reorder_today(user, ids, day)
      assert {:ok, ^original} = Tasks.snapshot(user, day)
    end
  end

  test "reorder_today revalidates stale sets after a return, selection or rollover", %{user: user} do
    day = ~D[2026-10-01]
    first = task_fixture(user)
    second = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, first.id, day)
    assert {:ok, _} = Tasks.select_today(user, second.id, day)
    assert {:ok, _} = Tasks.return_to_backlog(user, first.id, day)
    assert {:error, :invalid_order} = Tasks.reorder_today(user, [second.id, first.id], day)
    assert {:ok, _} = Tasks.select_today(user, first.id, day)
    assert {:error, :invalid_order} = Tasks.reorder_today(user, [second.id], day)

    assert {:error, :invalid_order} =
             Tasks.reorder_today(user, [second.id, first.id], Date.add(day, 1))

    assert {:ok, %{today: [], retry: retry, used_choices: 0}} =
             Tasks.snapshot(user, Date.add(day, 1))

    assert length(retry) == 2
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: day).used_choices == 2
  end

  test "reorder_today accepts an empty current set and the server date", %{user: user} do
    assert {:ok, []} = Tasks.reorder_today(user, [])
    assert {:ok, %{used_choices: 0}} = Tasks.snapshot(user)
  end

  test "reorder_today rolls back temporary positions after a final write failure", %{user: user} do
    day = ~D[2026-10-01]
    tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, original} = Tasks.snapshot(user, day)
    last = List.last(tasks)

    SQL.query!(
      Repo,
      "ALTER TABLE tasks ADD CONSTRAINT reject_test_order CHECK (id <> #{last.id} OR position <> 1) NOT VALID"
    )

    ids = tasks |> Enum.reverse() |> Enum.map(& &1.id)
    assert_raise Ecto.ConstraintError, fn -> Tasks.reorder_today(user, ids, day) end
    assert {:ok, ^original} = Tasks.snapshot(user, day)
  end

  test "position constraints reject duplicate, missing and nonpositive pending positions", %{
    user: user
  } do
    day = ~D[2026-10-01]
    first = task_fixture(user) |> schedule(day, 1)
    second = task_fixture(user)

    for attrs <- [
          [kind: :today, scheduled_for: day, position: 1],
          [kind: :today, scheduled_for: day],
          [position: 0],
          [position: -1],
          [kind: :today, position: 2]
        ] do
      assert_raise Ecto.ConstraintError, fn ->
        Repo.transaction(fn -> second |> change(attrs) |> Repo.update!() end)
      end
    end

    assert Repo.get!(Task, first.id) == first
    assert Repo.get!(Task, second.id) == second
    assert task_fixture(user_fixture()) |> schedule(day, 1)
  end

  test "reordering concurrently with return or selection preserves the resulting set and quota" do
    for operation <- [:return, :select] do
      with_committed_user(fn user ->
        day = ~D[2026-10-01]
        tasks = for _ <- 1..3, do: task_fixture(user)
        [first, second, third] = tasks
        for task <- [first, second], do: assert({:ok, _} = Tasks.select_today(user, task.id, day))

        mutation =
          case operation do
            :return -> fn -> Tasks.return_to_backlog(user, first.id, day) end
            :select -> fn -> Tasks.select_today(user, third.id, day) end
          end

        [order_result, mutation_result] =
          race_planning_commands(user, day, [
            fn -> Tasks.reorder_today(user, [second.id, first.id], day) end,
            mutation
          ])

        assert match?({:ok, _}, order_result) or order_result == {:error, :invalid_order}
        assert {:ok, _} = mutation_result
        assert {:ok, snapshot} = Tasks.snapshot(user, day)
        expected = if operation == :return, do: [second.id], else: Enum.map(tasks, & &1.id)
        assert Enum.sort(Enum.map(snapshot.today, & &1.id)) == Enum.sort(expected)
        assert snapshot.used_choices == length(expected)
        assert Enum.map(snapshot.today, & &1.position) == Enum.to_list(1..length(expected))
      end)
    end
  end

  test "return_to_backlog refunds once, compacts positions and permits reselection", %{user: user} do
    day = ~D[2026-10-01]
    label = label_fixture(user)
    tasks = for _ <- 1..3, do: task_fixture(user, %{label_ids: [label.id]})
    for task <- tasks, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    [first, middle, last] = tasks
    assert {:ok, returned} = Tasks.return_to_backlog(user, Integer.to_string(middle.id), day)
    assert returned.kind == :backlog
    assert returned.id == middle.id
    assert returned.title == middle.title
    assert is_nil(returned.position)
    assert Repo.preload(returned, :labels).labels == [label]
    assert {:ok, ^returned} = Tasks.return_to_backlog(user, middle.id, day)
    assert {:ok, %{used_choices: 2, today: today}} = Tasks.snapshot(user, day)
    assert Enum.map(today, &{&1.id, &1.position}) == [{first.id, 1}, {last.id, 2}]
    assert {:ok, reselected} = Tasks.select_today(user, middle.id, day)
    assert reselected.position == 3
    assert {:ok, %{used_choices: 3}} = Tasks.snapshot(user, day)
  end

  test "return_to_backlog rejects invalid owners, completion and expired selections", %{
    user: user
  } do
    day = ~D[2026-10-01]
    expired = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, expired.id, Date.add(day, -1))
    completed = task_fixture(user)
    assert {:ok, completed} = Tasks.select_today(user, completed.id, day)
    completed = completed |> change(completed_on: day) |> Repo.update!()
    foreign = task_fixture(user_fixture()) |> schedule(day, 1)

    for id <- [nil, "bad-id", -1, foreign.id] do
      assert {:error, :not_found} = Tasks.return_to_backlog(user, id, day)
    end

    for id <- [expired.id, completed.id] do
      assert {:error, :invalid_state} = Tasks.return_to_backlog(user, id, day)
    end

    assert Repo.get!(Task, completed.id) == completed
    assert Repo.get!(Task, foreign.id) == foreign
    assert {:ok, %{used_choices: 1, retry: [retry]}} = Tasks.snapshot(user, day)
    assert retry.id == expired.id
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: Date.add(day, -1)).used_choices == 1
  end

  test "return_to_backlog rolls back task, positions and quota after a refund write failure", %{
    user: user
  } do
    day = ~D[2026-10-01]
    tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, original} = Tasks.snapshot(user, day)

    SQL.query!(
      Repo,
      "ALTER TABLE daily_plans ADD CONSTRAINT reject_test_refund CHECK (used_choices = 3) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn -> Tasks.return_to_backlog(user, hd(tasks).id, day) end
    assert {:ok, ^original} = Tasks.snapshot(user, day)
  end

  test "return_to_backlog handles a single task and uses the server day", %{user: user} do
    task = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, task.id)
    assert {:ok, returned} = Tasks.return_to_backlog(user, task.id)
    assert returned.kind == :backlog
    assert {:ok, %{used_choices: 0, today: []}} = Tasks.snapshot(user)
  end

  test "a stale return command cannot refund yesterday's choice into a new day", %{user: user} do
    yesterday = ~D[2026-09-30]
    day = Date.add(yesterday, 1)
    task = task_fixture(user)
    assert {:ok, selected} = Tasks.select_today(user, task.id, yesterday)
    assert {:error, :invalid_state} = Tasks.return_to_backlog(user, task.id, day)
    assert Repo.get_by(DailyPlan, user_id: user.id, day: day) == nil
    assert Repo.get!(Task, task.id) == selected
    assert {:ok, %{used_choices: 0, today: [], retry: [retry]}} = Tasks.snapshot(user, day)
    assert retry.id == task.id
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: yesterday).used_choices == 1
  end

  test "concurrent returns refund the same task only once" do
    with_committed_user(fn user ->
      day = ~D[2026-10-01]
      task = task_fixture(user)
      assert {:ok, _} = Tasks.select_today(user, task.id, day)
      command = fn -> Tasks.return_to_backlog(user, task.id, day) end
      assert [{:ok, first}, {:ok, second}] = race_planning_commands(user, day, [command, command])
      assert first == second
      assert {:ok, %{used_choices: 0, today: [], backlog: [returned]}} = Tasks.snapshot(user, day)
      assert returned.id == task.id
    end)
  end

  test "concurrent return and selection preserve the quota and consecutive positions" do
    with_committed_user(fn user ->
      day = ~D[2026-10-01]
      tasks = for _ <- 1..4, do: task_fixture(user)

      for task <- Enum.take(tasks, 3),
          do: assert({:ok, _} = Tasks.select_today(user, task.id, day))

      [returning, _, _, selecting] = tasks

      [return_result, select_result] =
        race_planning_commands(user, day, [
          fn -> Tasks.return_to_backlog(user, returning.id, day) end,
          fn -> Tasks.select_today(user, selecting.id, day) end
        ])

      assert {:ok, %{kind: :backlog}} = return_result
      assert {:ok, snapshot} = Tasks.snapshot(user, day)

      case select_result do
        {:ok, selected} ->
          assert selected.id == selecting.id
          assert snapshot.used_choices == 3
          assert length(snapshot.today) == 3

        {:error, :quota_exhausted} ->
          assert snapshot.used_choices == 2
          assert length(snapshot.today) == 2
      end

      assert Enum.map(snapshot.today, & &1.position) == Enum.to_list(1..length(snapshot.today))
      assert Enum.any?(snapshot.backlog, &(&1.id == returning.id))
    end)
  end

  defp with_committed_user(operation) do
    Sandbox.unboxed_run(Repo, fn ->
      user = user_fixture()

      try do
        operation.(user)
      after
        Repo.delete_all(from t in Task, where: t.user_id == ^user.id)
        Repo.delete_all(from p in DailyPlan, where: p.user_id == ^user.id)
        Repo.delete!(user)
      end
    end)
  end

  defp race_planning_commands(user, day, commands) do
    parent = self()

    holder =
      selection_worker(fn ->
        UserTransaction.run(
          user,
          fn _day, _plan ->
            send(parent, {:holder, selection_backend()})
            receive do: (:release -> {:ok, :released})
          end,
          day
        )
      end)

    assert_receive {:holder, holder_backend}, 2_000

    contenders =
      Enum.map(commands, fn command ->
        selection_worker(fn ->
          send(parent, {:contender, selection_backend()})
          command.()
        end)
      end)

    try do
      assert_receive {:contender, first_backend}, 2_000
      assert_receive {:contender, second_backend}, 2_000
      assert first_backend != second_backend
      deadline = System.monotonic_time(:millisecond) + 2_000
      wait_for_selection_lock(first_backend, [holder_backend, second_backend], deadline)
      wait_for_selection_lock(second_backend, [holder_backend, first_backend], deadline)
    after
      send(holder.pid, :release)
    end

    assert {:ok, :released} = Elixir.Task.await(holder)
    Enum.map(contenders, &Elixir.Task.await/1)
  end

  test "select_today uses three choices, appends positions and is idempotent at the limit", %{
    user: user
  } do
    day = ~D[2026-10-01]
    tasks = for _ <- 1..4, do: task_fixture(user)

    for {task, position} <- Enum.zip(Enum.take(tasks, 3), 1..3) do
      assert {:ok, selected} = Tasks.select_today(user, task.id, day)
      assert selected.id == task.id
      assert selected.kind == :today
      assert selected.scheduled_for == day
      assert selected.position == position
    end

    assert {:ok, first} = Tasks.select_today(user, hd(tasks).id, day)
    assert first.position == 1
    assert {:error, :quota_exhausted} = Tasks.select_today(user, List.last(tasks).id, day)

    assert {:ok, %{used_choices: 3, today: today, backlog: [remaining]}} =
             Tasks.snapshot(user, day)

    assert length(today) == 3
    assert remaining.id == List.last(tasks).id
  end

  test "select_today rejects foreign, missing, malformed and completed tasks", %{user: user} do
    day = ~D[2026-10-01]
    foreign = task_fixture(user_fixture())
    completed = task_fixture(user) |> schedule(day, 1)
    completed = completed |> change(completed_on: day) |> Repo.update!()

    for id <- [foreign.id, -1, "bad-id", nil] do
      assert {:error, :not_found} = Tasks.select_today(user, id, day)
    end

    assert {:error, :invalid_state} = Tasks.select_today(user, completed.id, day)
    assert Repo.get!(Task, foreign.id) == foreign
    assert Repo.get!(Task, completed.id) == completed
    assert Repo.get_by(DailyPlan, user_id: user.id, day: day) == nil
  end

  test "select_today captures the server day and keeps each user's quota independent", %{
    user: user
  } do
    before = Date.utc_today()

    for _ <- 1..3 do
      task = task_fixture(user)
      assert {:ok, selected} = Tasks.select_today(user, task.id)
      assert selected.scheduled_for in [before, Date.utc_today()]
    end

    other = user_fixture()
    task = task_fixture(other)
    assert {:ok, selected} = Tasks.select_today(other, task.id)
    assert selected.user_id == other.id
    assert selected.position == 1
    assert {:ok, %{used_choices: 1}} = Tasks.snapshot(other)
  end

  test "select_today revalidates rollover and consumes the current day's quota", %{user: user} do
    yesterday = ~D[2026-09-30]
    day = Date.add(yesterday, 1)
    label = label_fixture(user)
    stale = task_fixture(user, %{label_ids: [label.id]})
    abandoned = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, stale.id, yesterday)
    assert {:ok, _} = Tasks.select_today(user, abandoned.id, yesterday)
    assert {:ok, selected} = Tasks.select_today(user, Integer.to_string(stale.id), day)
    assert selected.id == stale.id
    assert selected.title == stale.title
    assert selected.position == 1
    assert selected.scheduled_for == day
    assert Repo.preload(selected, :labels).labels == [label]
    assert {:ok, %{used_choices: 1, retry: [retry]}} = Tasks.snapshot(user, day)
    assert retry.id == abandoned.id
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: yesterday).used_choices == 2
  end

  test "select_today rolls back the movement when the quota write fails", %{user: user} do
    day = ~D[2026-10-01]
    task = task_fixture(user)
    assert {:ok, _} = Tasks.snapshot(user, day)

    SQL.query!(
      Repo,
      "ALTER TABLE daily_plans ADD CONSTRAINT reject_test_consumption CHECK (used_choices = 0) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn -> Tasks.select_today(user, task.id, day) end
    assert Repo.get!(Task, task.id) == task
    assert Repo.get_by!(DailyPlan, user_id: user.id, day: day).used_choices == 0
  end

  test "concurrent selections on separate connections have one winner for the last choice" do
    Sandbox.unboxed_run(Repo, fn ->
      user = user_fixture()

      try do
        day = ~D[2026-10-01]
        first = task_fixture(user)
        second = task_fixture(user)
        Repo.insert!(%DailyPlan{user_id: user.id, day: day, used_choices: 2})
        parent = self()

        holder =
          selection_worker(fn ->
            UserTransaction.run(
              user,
              fn _day, _plan ->
                send(parent, {:holder, selection_backend()})
                receive do: (:release -> {:ok, :released})
              end,
              day
            )
          end)

        assert_receive {:holder, holder_backend}, 2_000

        contenders =
          for task <- [first, second] do
            selection_worker(fn ->
              send(parent, {:contender, selection_backend()})
              Tasks.select_today(user, task.id, day)
            end)
          end

        try do
          assert_receive {:contender, first_backend}, 2_000
          assert_receive {:contender, second_backend}, 2_000
          assert first_backend != second_backend
          deadline = System.monotonic_time(:millisecond) + 2_000
          wait_for_selection_lock(first_backend, [holder_backend, second_backend], deadline)
          wait_for_selection_lock(second_backend, [holder_backend, first_backend], deadline)
        after
          send(holder.pid, :release)
        end

        assert {:ok, :released} = Elixir.Task.await(holder)
        results = Enum.map(contenders, &Elixir.Task.await/1)
        assert Enum.count(results, &match?({:ok, %Task{}}, &1)) == 1
        assert Enum.count(results, &(&1 == {:error, :quota_exhausted})) == 1

        assert {:ok, %{used_choices: 3, today: [winner], backlog: [loser]}} =
                 Tasks.snapshot(user, day)

        assert winner.id != loser.id
        assert winner.position == 1
        assert {:ok, _} = Tasks.select_today(user, winner.id, day)
        assert Repo.get_by!(DailyPlan, user_id: user.id, day: day).used_choices == 3
      after
        Repo.delete_all(from t in Task, where: t.user_id == ^user.id)
        Repo.delete_all(from p in DailyPlan, where: p.user_id == ^user.id)
        Repo.delete!(user)
      end
    end)
  end

  defp selection_worker(fun) do
    supervisor = start_supervised!({Elixir.Task.Supervisor, name: nil}, id: make_ref())

    Elixir.Task.Supervisor.async_nolink(supervisor, fn ->
      Sandbox.unboxed_run(Repo, fun)
    end)
  end

  defp selection_backend, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  defp wait_for_selection_lock(waiter, expected_blockers, deadline) do
    %{rows: [[blockers]]} = Repo.query!("SELECT pg_blocking_pids($1)", [waiter])

    unless Enum.any?(blockers, &(&1 in expected_blockers)) do
      assert System.monotonic_time(:millisecond) < deadline, "expected PostgreSQL lock wait"
      wait_for_selection_lock(waiter, expected_blockers, deadline)
    end
  end

  test "snapshot rolls expired pending tasks into retry once and preserves identity", %{
    user: user
  } do
    day = ~D[2026-10-01]
    yesterday = Date.add(day, -1)
    label = label_fixture(user)
    expired = task_fixture(user, %{label_ids: [label.id]}) |> schedule(yesterday, 1)
    completed = task_fixture(user) |> schedule(yesterday, 2)
    completed = completed |> change(completed_on: yesterday) |> Repo.update!()
    current = task_fixture(user) |> schedule(day, 1)
    foreign = task_fixture(user_fixture()) |> schedule(yesterday, 1)

    assert {:ok, snapshot} = Tasks.snapshot(user, day)
    assert snapshot.day == day
    assert snapshot.used_choices == 0
    assert snapshot.available_choices == 3
    assert Enum.map(snapshot.today, & &1.id) == [current.id]
    assert [retry] = snapshot.retry
    assert retry.id == expired.id
    assert retry.title == expired.title
    assert retry.kind == :retry
    assert retry.scheduled_for == yesterday
    assert is_nil(retry.position)
    assert is_nil(retry.completed_on)
    assert Repo.preload(retry, :labels).labels == [label]
    assert Repo.get!(Task, completed.id) == completed
    assert Repo.get!(Task, foreign.id) == foreign
    assert {:ok, ^snapshot} = Tasks.snapshot(user, day)
  end

  test "snapshot orders each pending collection and reads persisted quota", %{user: user} do
    day = ~D[2026-10-01]
    first = task_fixture(user)
    second = task_fixture(user)
    older = task_fixture(user)
    retry_first = task_fixture(user) |> schedule(Date.add(day, -1), 2)
    retry_second = task_fixture(user) |> schedule(Date.add(day, -1), 1)
    today_second = task_fixture(user) |> schedule(day, 2)
    today_first = task_fixture(user) |> schedule(day, 1)

    Repo.update_all(from(t in Task, where: t.user_id == ^user.id),
      set: [inserted_at: ~U[2026-01-02 00:00:00Z]]
    )

    older |> change(inserted_at: ~U[2026-01-01 00:00:00Z]) |> Repo.update!()
    Repo.insert!(%DailyPlan{user_id: user.id, day: day, used_choices: 3})

    assert {:ok, snapshot} = Tasks.snapshot(user, day)
    assert Enum.map(snapshot.backlog, & &1.id) == [older.id, first.id, second.id]
    assert Enum.map(snapshot.retry, & &1.id) == [retry_first.id, retry_second.id]
    assert Enum.map(snapshot.today, & &1.id) == [today_first.id, today_second.id]
    assert snapshot.used_choices == 3
    assert snapshot.available_choices == 0
  end

  test "a stale command sees normalization before validation and rejection rolls it back", %{
    user: user
  } do
    day = ~D[2026-10-01]
    stale = task_fixture(user) |> schedule(Date.add(day, -1), 1)

    assert {:error, :stale_task} =
             UserTransaction.run(
               user,
               fn captured, plan ->
                 assert captured == day
                 assert plan.day == day
                 normalized = Repo.get!(Task, stale.id)
                 assert normalized.kind == :retry
                 assert is_nil(normalized.position)
                 {:error, :stale_task}
               end,
               day
             )

    assert Repo.get!(Task, stale.id) == stale
    assert Repo.get_by(DailyPlan, user_id: user.id, day: day) == nil
    assert {:ok, %{retry: [%{id: id}]}} = Tasks.snapshot(user, day)
    assert id == stale.id
  end

  test "snapshot defaults to the server day", %{user: user} do
    before = Date.utc_today()
    assert {:ok, snapshot} = Tasks.snapshot(user)
    assert snapshot.day in [before, Date.utc_today()]
    assert snapshot.backlog == []
    assert snapshot.today == []
    assert snapshot.retry == []
  end

  test "snapshot survives a repository and connection pool restart across a day change" do
    name = __MODULE__.RestartRepo

    spec =
      Supervisor.child_spec({Repo, name: name, pool: DBConnection.ConnectionPool, pool_size: 1},
        id: name
      )

    first_pid = start_supervised!(spec)
    original_repo = Repo.put_dynamic_repo(name)
    user = user_fixture()

    try do
      day = ~D[2026-10-01]
      pending = task_fixture(user) |> schedule(day, 1)
      backlog = task_fixture(user)
      Repo.insert!(%DailyPlan{user_id: user.id, day: day, used_choices: 3})
      Repo.insert!(%DailyPlan{user_id: user.id, day: Date.add(day, 1), used_choices: 2})
      assert {:ok, before} = Tasks.snapshot(user, day)
      backend = Repo.query!("SELECT pg_backend_pid()").rows
      monitor = Process.monitor(first_pid)
      stop_supervised!(name)
      assert_receive {:DOWN, ^monitor, :process, ^first_pid, :shutdown}
      assert start_supervised!(spec) != first_pid
      assert Repo.query!("SELECT pg_backend_pid()").rows != backend
      assert {:ok, ^before} = Tasks.snapshot(user, day)
      assert {:ok, after_rollover} = Tasks.snapshot(user, Date.add(day, 1))
      assert after_rollover.used_choices == 2
      assert after_rollover.available_choices == 1
      assert after_rollover.today == []
      assert Enum.map(after_rollover.retry, & &1.id) == [pending.id]
      assert Enum.map(after_rollover.backlog, & &1.id) == [backlog.id]
      assert Repo.get_by!(DailyPlan, user_id: user.id, day: day).used_choices == 3
    after
      Repo.delete_all(from t in Task, where: t.user_id == ^user.id)
      Repo.delete_all(from p in DailyPlan, where: p.user_id == ^user.id)
      Repo.delete!(user)
      Repo.put_dynamic_repo(original_repo)
    end
  end

  defp schedule(task, day, position) do
    task |> change(kind: :today, scheduled_for: day, position: position) |> Repo.update!()
  end

  test "create_task/2 creates distinct backlog tasks from trimmed titles", %{user: user} do
    assert {:ok, %Task{} = task} = Tasks.create_task(user, %{title: "  some title  "})
    assert task.title == "some title"
    assert task.user_id == user.id
    assert task.kind == :backlog
    assert is_nil(task.scheduled_for)
    assert is_nil(task.completed_on)
    assert is_nil(task.position)
    assert Repo.preload(task, :labels).labels == []
    assert Tasks.get_task!(user, task.id) == task
    assert {:ok, duplicate} = Tasks.create_task(user, %{title: task.title})
    refute duplicate.id == task.id
  end

  test "create_task/2 persists a title longer than 255 characters", %{user: user} do
    title = String.duplicate("a", 256)
    assert {:ok, task} = Tasks.create_task(user, %{title: title})
    assert Tasks.get_task!(user, task.id).title == title
  end

  test "create_task/2 rejects missing, blank and nontextual titles without persisting", %{
    user: user
  } do
    for title <- [nil, "", "  ", "\t\n", "\u00A0", 42, true, ["title"], %{}] do
      assert {:error, %Ecto.Changeset{valid?: false} = changeset} =
               Tasks.create_task(user, %{title: title})

      assert errors_on(changeset).title
    end

    assert {:error, %Ecto.Changeset{}} = Tasks.create_task(user)
    assert Tasks.list_tasks(user) == []
  end

  test "create_task/2 ignores forged owner, state, dates and position", %{user: user} do
    other = user_fixture()

    attrs = %{
      title: "some title",
      user_id: other.id,
      kind: :today,
      scheduled_for: ~D[2026-09-25],
      completed_on: ~D[2026-09-25],
      position: 1
    }

    for forged <- [attrs, Map.new(attrs, fn {key, value} -> {Atom.to_string(key), value} end)] do
      assert {:ok, task} = Tasks.create_task(user, forged)
      assert task.user_id == user.id
      assert task.kind == :backlog
      assert is_nil(task.scheduled_for)
      assert is_nil(task.completed_on)
      assert is_nil(task.position)
    end

    assert Tasks.list_tasks(other) == []
  end

  test "list_tasks/1 returns only owned tasks in creation and ID order", %{user: user} do
    first = task_fixture(user)
    second = task_fixture(user)
    older = task_fixture(user)
    task_fixture(user_fixture())
    timestamp = ~U[2026-01-02 00:00:00Z]
    Repo.update_all(Task, set: [inserted_at: timestamp])

    Repo.update_all(from(t in Task, where: t.id == ^older.id),
      set: [inserted_at: ~U[2026-01-01 00:00:00Z]]
    )

    assert Enum.map(Tasks.list_tasks(user), & &1.id) == [older.id, first.id, second.id]
  end

  test "get_task!/2 treats foreign and missing IDs alike", %{user: user} do
    task = task_fixture(user)
    assert Tasks.get_task!(user, task.id) == task
    assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(user_fixture(), task.id) end
    assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(user, -1) end
    assert Tasks.get_task!(user, task.id) == task
  end

  test "change_task/2 builds a registration changeset for the explicit user", %{user: user} do
    assert %Ecto.Changeset{} = Tasks.change_task(user)
    changeset = Tasks.change_task(user, %{title: "  some title  ", user_id: -1, kind: :retry})
    assert changeset.valid?
    task = Ecto.Changeset.apply_changes(changeset)
    assert task.title == "some title"
    assert task.user_id == user.id
    assert task.kind == :backlog
    assert Tasks.list_tasks(user) == []
  end

  test "create_task/2 rejects absent and nonexistent owners" do
    for owner <- [%Planner.Accounts.User{}, %Planner.Accounts.User{id: -1}] do
      assert {:error, changeset} = Tasks.create_task(owner, %{title: "some title"})
      assert errors_on(changeset).user_id
    end
  end

  test "create_task/2 associates distinct owned labels and accepts repeated IDs", %{user: user} do
    first = label_fixture(user, %{name: "First"})
    second = label_fixture(user, %{name: "Second"})

    assert {:ok, task} =
             Tasks.create_task(user, %{
               title: "With labels",
               label_ids: [first.id, Integer.to_string(first.id), second.id]
             })

    assert Enum.sort(Enum.map(Repo.preload(task, :labels).labels, & &1.id)) ==
             Enum.sort([first.id, second.id])

    assert Repo.aggregate(TaskLabel, :count) == 2
  end

  test "create_task/2 creates new labels alongside existing ones in one registration", %{
    user: user
  } do
    existing = label_fixture(user, %{name: "Existing"})

    assert {:ok, task} =
             Tasks.create_task(user, %{
               "title" => "Mixed",
               "label_ids" => [Integer.to_string(existing.id)],
               "new_label_names" => ["  New one  ", "New two"]
             })

    assert Enum.sort(Enum.map(Repo.preload(task, :labels).labels, & &1.name)) ==
             ["Existing", "New one", "New two"]

    assert Enum.sort(Enum.map(Labels.list_labels(user), & &1.name)) ==
             ["Existing", "New one", "New two"]
  end

  test "create_task/2 rolls back a task and all new labels after an invalid label name", %{
    user: user
  } do
    existing = label_fixture(user, %{name: "Existing"})

    assert {:error, changeset} =
             Tasks.create_task(user, %{
               title: "Must roll back",
               label_ids: [existing.id],
               new_label_names: ["First new", "  "]
             })

    assert errors_on(changeset).new_label_names
    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == [existing]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "create_task/2 rolls back requested labels when title is invalid", %{user: user} do
    assert {:error, changeset} =
             Tasks.create_task(user, %{title: "  ", new_label_names: ["New"]})

    assert errors_on(changeset).title
    assert Tasks.list_tasks(user) == []
    assert Repo.aggregate(Label, :count) == 0
  end

  test "create_task/2 rolls back task and new labels after a link write fails", %{
    user: user
  } do
    existing = label_fixture(user, %{name: "Existing"})

    SQL.query!(
      Repo,
      "ALTER TABLE task_labels ADD CONSTRAINT reject_test_links CHECK (false) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn ->
      Tasks.create_task(user, %{
        title: "Must roll back",
        label_ids: [existing.id],
        new_label_names: ["New"]
      })
    end

    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == [existing]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "create_task/2 rejects foreign and missing labels without partial records", %{
    user: user
  } do
    existing = label_fixture(user, %{name: "Existing"})
    foreign = label_fixture(user_fixture(), %{name: "Private"})

    for invalid_id <- [foreign.id, -1] do
      assert {:error, changeset} =
               Tasks.create_task(user, %{
                 title: "Must roll back",
                 label_ids: [existing.id, invalid_id],
                 new_label_names: ["New"]
               })

      assert errors_on(changeset).label_ids
    end

    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == [existing]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "create_task/2 rejects malformed label input without partial records", %{user: user} do
    for label_ids <- [["not-an-id"], [nil], "1"] do
      assert {:error, changeset} =
               Tasks.create_task(user, %{
                 title: "Invalid IDs",
                 label_ids: label_ids,
                 new_label_names: ["New"]
               })

      assert errors_on(changeset).label_ids
    end

    for new_label_names <- [[42], "New"] do
      assert {:error, changeset} =
               Tasks.create_task(user, %{
                 title: "Invalid names",
                 new_label_names: new_label_names
               })

      assert errors_on(changeset).new_label_names
    end

    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == []
    assert Repo.aggregate(TaskLabel, :count) == 0
  end
end
