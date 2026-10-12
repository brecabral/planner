defmodule Planner.TaskMovementTest do
  use Planner.DataCase

  import Planner.AccountsFixtures
  import Planner.TasksFixtures

  alias Planner.Tasks

  test "each pending list persists its order and registration appends" do
    user = user_fixture()
    first = task_fixture(user)
    second = task_fixture(user)
    assert {:ok, _} = Tasks.reorder_list(user, :backlog, [second.id, first.id])
    third = task_fixture(user)
    assert {:ok, snapshot} = Tasks.snapshot(user)

    assert Enum.map(snapshot.backlog, &{&1.id, &1.position}) ==
             [{second.id, 1}, {first.id, 2}, {third.id, 3}]
  end

  test "moving into an empty destination updates quota and compacts the origin" do
    user = user_fixture()
    first = task_fixture(user)
    second = task_fixture(user)

    assert {:ok, _} =
             Tasks.move_task(user, %{
               "task_id" => first.id,
               "from" => "backlog",
               "to" => "today",
               "orders" => %{"backlog" => [second.id], "today" => [first.id]}
             })

    assert {:ok, %{used_choices: 1, today: [today], backlog: [backlog]}} = Tasks.snapshot(user)
    assert {today.id, today.position} == {first.id, 1}
    assert {backlog.id, backlog.position} == {second.id, 1}

    assert {:ok, _} =
             Tasks.move_task(user, %{
               "task_id" => first.id,
               "from" => "today",
               "to" => "backlog",
               "orders" => %{"backlog" => [first.id, second.id], "today" => []}
             })

    assert {:ok, %{used_choices: 0, today: [], backlog: tasks}} = Tasks.snapshot(user)
    assert Enum.map(tasks, & &1.id) == [first.id, second.id]
  end

  test "reordering all lists and rollover preserve priority and quota" do
    user = user_fixture()
    day = ~D[2026-10-01]
    [a, b, c, d] = for _ <- 1..4, do: task_fixture(user)
    for task <- [a, b], do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, _} = Tasks.reorder_today(user, [b.id, a.id], day)
    assert {:ok, %{retry: retry}} = Tasks.snapshot(user, Date.add(day, 1))
    assert Enum.map(retry, & &1.id) == [b.id, a.id]
    assert {:ok, _} = Tasks.reorder_list(user, "retry", [a.id, b.id], Date.add(day, 1))
    for task <- [c, d], do: assert({:ok, _} = Tasks.select_today(user, task.id, Date.add(day, 1)))
    assert {:ok, _} = Tasks.reorder_today(user, [d.id, c.id], Date.add(day, 1))
    assert {:ok, %{used_choices: 2}} = Tasks.snapshot(user, Date.add(day, 1))
    assert {:ok, snapshot} = Tasks.snapshot(user, Date.add(day, 2))

    assert Enum.map(snapshot.retry, &{&1.id, &1.position}) ==
             [{a.id, 1}, {b.id, 2}, {d.id, 3}, {c.id, 4}]

    assert {:ok, ^snapshot} = Tasks.snapshot(user, Date.add(day, 2))
  end

  for index <- 0..2 do
    test "transfer inserts at destination index #{index} and menu appends" do
      user = user_fixture()
      label = Planner.LabelsFixtures.label_fixture(user)
      [a, b, moving, remaining] = for _ <- 1..4, do: task_fixture(user, %{label_ids: [label.id]})
      for task <- [a, b], do: assert({:ok, _} = Tasks.select_today(user, task.id))
      ids = List.insert_at([a.id, b.id], unquote(index), moving.id)

      assert {:ok, _} =
               Tasks.move_task(
                 user,
                 payload(moving, "backlog", "today", %{
                   "today" => ids,
                   "backlog" => [remaining.id]
                 })
               )

      assert {:ok, snapshot} = Tasks.snapshot(user)
      assert Enum.map(snapshot.today, & &1.id) == ids
      assert Enum.map(snapshot.today, & &1.position) == [1, 2, 3]
      assert Enum.all?(snapshot.today, &(&1.labels == [label]))
      assert snapshot.used_choices == 3
      assert {:ok, returned} = Tasks.return_to_backlog(user, moving.id)
      assert returned.position == 2
      assert {:ok, selected} = Tasks.select_today(user, moving.id)
      assert selected.position == 3
    end
  end

  test "retry transfer compacts its origin and consumes a current choice" do
    user = user_fixture()
    [a, b] = for _ <- 1..2, do: task_fixture(user)
    day = ~D[2026-10-01]
    for task <- [a, b], do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
    assert {:ok, _} = Tasks.snapshot(user, Date.add(day, 1))

    assert {:ok, _} =
             Tasks.move_task(
               user,
               payload(a, "retry", "today", %{
                 "retry" => [b.id],
                 "today" => [a.id]
               }),
               Date.add(day, 1)
             )

    assert {:ok, %{used_choices: 1, retry: [%{id: id, position: 1}]}} =
             Tasks.snapshot(user, Date.add(day, 1))

    assert id == b.id
  end

  test "invalid payloads leave every list and quota unchanged" do
    user = user_fixture()
    [a, b] = for _ <- 1..2, do: task_fixture(user)
    foreign = task_fixture(user_fixture())
    assert {:ok, before} = Tasks.snapshot(user)

    for params <- [
          %{},
          payload(a, "backlog", "today", %{"today" => [a.id], "backlog" => []}),
          payload(a, "backlog", "today", %{"today" => [a.id, a.id], "backlog" => [b.id]}),
          payload(a, "backlog", "today", %{"today" => [a.id], "backlog" => [foreign.id]}),
          payload(a, "backlog", "today", %{"today" => [a.id], "backlog" => ["bad"]}),
          payload(a, "backlog", "today", %{"today" => [a.id], "backlog" => nil}),
          payload(a, "backlog", "retry", %{"retry" => [a.id], "backlog" => [b.id]}),
          payload(a, "retry", "today", %{"today" => [a.id], "retry" => []}),
          payload(a, "history", "today", %{}),
          payload(foreign, "backlog", "today", %{
            "today" => [foreign.id],
            "backlog" => [a.id, b.id]
          }),
          payload(%{id: "invalid"}, "backlog", "today", %{}),
          payload(a, "backlog", "backlog", %{"backlog" => [b.id, a.id], "retry" => []})
        ] do
      assert {:error, _} = Tasks.move_task(user, params)
      assert {:ok, ^before} = Tasks.snapshot(user)
    end

    for ids <- [[a.id], [a.id, a.id], [a.id, foreign.id], nil] do
      assert {:error, :invalid_order} = Tasks.reorder_list(user, :backlog, ids)
    end

    assert {:error, :invalid_order} = Tasks.reorder_list(user, "unknown", [])
    assert {:ok, ^before} = Tasks.snapshot(user)
  end

  test "completed tasks, exhausted quota and stale sets are rejected" do
    user = user_fixture()
    [a, b, c, d] = for _ <- 1..4, do: task_fixture(user)
    for task <- [a, b, c], do: assert({:ok, _} = Tasks.select_today(user, task.id))
    assert {:ok, _} = Tasks.complete_task(user, a.id)
    assert {:ok, before} = Tasks.snapshot(user)

    assert {:error, :quota_exhausted} =
             Tasks.move_task(
               user,
               payload(d, "backlog", "today", %{
                 "today" => [b.id, d.id, c.id],
                 "backlog" => []
               })
             )

    assert {:error, :invalid_state} =
             Tasks.move_task(
               user,
               payload(a, "today", "backlog", %{
                 "today" => [b.id, c.id],
                 "backlog" => [d.id, a.id]
               })
             )

    assert {:ok, ^before} = Tasks.snapshot(user)
    extra = task_fixture(user)

    assert {:error, :invalid_order} =
             Tasks.move_task(user, payload(d, "backlog", "backlog", %{"backlog" => [d.id]}))

    assert {:ok, %{backlog: [_, %{id: id}]}} = Tasks.snapshot(user)
    assert id == extra.id
  end

  test "failed final order rolls back transfer, quota and rollover" do
    user = user_fixture()
    day = ~D[2026-10-01]
    [expired, moving, remaining] = for _ <- 1..3, do: task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, expired.id, day)
    before = Tasks.list_tasks(user)
    # The transfer and quota write succeed; its final order then fails.
    Repo.query!(
      "ALTER TABLE tasks ADD CONSTRAINT reject_movement_order CHECK (id != #{moving.id} OR kind != 'today' OR position = 1) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn ->
      Tasks.move_task(
        user,
        payload(moving, "backlog", "today", %{
          "today" => [moving.id],
          "backlog" => [remaining.id]
        }),
        Date.add(day, 1)
      )
    end

    assert Tasks.list_tasks(user) == before
    assert Repo.get_by(Planner.Tasks.DailyPlan, user_id: user.id, day: Date.add(day, 1)) == nil
  end

  for index <- 0..2 do
    test "retry to backlog inserts at index #{index} with exhausted quota" do
      user = user_fixture()
      day = ~D[2026-10-02]
      label = Planner.LabelsFixtures.label_fixture(user)
      [moving, remaining] = for _ <- 1..2, do: task_fixture(user, %{label_ids: [label.id]})

      for task <- [moving, remaining],
          do: assert({:ok, _} = Tasks.select_today(user, task.id, Date.add(day, -1)))

      [a, b | selected] = for _ <- 1..5, do: task_fixture(user)
      for task <- selected, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
      ids = List.insert_at([a.id, b.id], unquote(index), moving.id)

      assert {:ok, _} =
               Tasks.move_task(
                 user,
                 payload(moving, "retry", "backlog", %{
                   "retry" => [remaining.id],
                   "backlog" => ids
                 }),
                 day
               )

      assert {:ok, snapshot} = Tasks.snapshot(user, day)
      assert snapshot.used_choices == 3
      assert Enum.map(snapshot.backlog, & &1.id) == ids
      assert Enum.map(snapshot.backlog, & &1.position) == [1, 2, 3]
      moved = Enum.find(snapshot.backlog, &(&1.id == moving.id))
      assert moved.title == moving.title
      assert moved.labels == [label]
      assert [%{id: remaining_id, position: 1}] = snapshot.retry
      assert remaining_id == remaining.id
      assert {:ok, returned} = Tasks.return_to_backlog(user, remaining.id, day)
      assert returned.position == 4
      assert {:ok, %{used_choices: 3, retry: []}} = Tasks.snapshot(user, day)
    end
  end

  test "retry transfer to empty backlog rejects stale, foreign and incomplete orders atomically" do
    user = user_fixture()
    day = ~D[2026-10-02]
    moving = task_fixture(user)
    foreign = task_fixture(user_fixture())
    assert {:ok, _} = Tasks.select_today(user, moving.id, Date.add(day, -1))
    assert {:ok, before} = Tasks.snapshot(user, day)

    for params <- [
          payload(moving, "today", "backlog", %{"today" => [], "backlog" => [moving.id]}),
          payload(moving, "retry", "backlog", %{"retry" => []}),
          payload(moving, "retry", "backlog", %{
            "retry" => [],
            "backlog" => [moving.id, foreign.id]
          }),
          payload(foreign, "retry", "backlog", %{"retry" => [], "backlog" => [foreign.id]}),
          payload(moving, "retry", "backlog", %{"retry" => [moving.id], "backlog" => [moving.id]})
        ] do
      assert {:error, _} = Tasks.move_task(user, params, day)
      assert {:ok, ^before} = Tasks.snapshot(user, day)
    end

    params = payload(moving, "retry", "backlog", %{"retry" => [], "backlog" => [moving.id]})
    assert {:ok, _} = Tasks.move_task(user, params, day)
    assert {:ok, after_move} = Tasks.snapshot(user, day)
    assert after_move.used_choices == 0
    assert [%{id: id, position: 1}] = after_move.backlog
    assert id == moving.id
    assert {:error, :invalid_state} = Tasks.move_task(user, params, day)
    assert {:ok, ^after_move} = Tasks.snapshot(user, day)
  end

  test "today to retry is forbidden and a drag across rollover keeps its original source" do
    user = user_fixture()
    day = ~D[2026-10-02]
    moving = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, moving.id, day)
    before = Tasks.list_tasks(user)

    assert {:error, :invalid_state} =
             Tasks.move_task(
               user,
               payload(moving, "today", "retry", %{"today" => [], "retry" => [moving.id]}),
               day
             )

    assert Tasks.list_tasks(user) == before
    next_day = Date.add(day, 1)

    assert {:error, :invalid_state} =
             Tasks.move_task(
               user,
               payload(moving, "today", "backlog", %{"today" => [], "backlog" => [moving.id]}),
               next_day
             )

    assert Tasks.list_tasks(user) == before

    assert {:ok, %{used_choices: 0, backlog: [], today: [], retry: [retry]}} =
             Tasks.snapshot(user, next_day)

    assert retry.id == moving.id
  end

  test "retry final order failure rolls back the transfer and rollover" do
    user = user_fixture()
    day = ~D[2026-10-02]
    [moving, expired] = for _ <- 1..2, do: task_fixture(user)

    for task <- [moving, expired],
        do: assert({:ok, _} = Tasks.select_today(user, task.id, Date.add(day, -1)))

    before = Tasks.list_tasks(user)

    Repo.query!(
      "ALTER TABLE tasks ADD CONSTRAINT reject_retry_order CHECK (id != #{moving.id} OR kind != 'backlog' OR position = 1) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn ->
      Tasks.move_task(
        user,
        payload(moving, "retry", "backlog", %{"retry" => [expired.id], "backlog" => [moving.id]}),
        day
      )
    end

    assert Tasks.list_tasks(user) == before
    assert Repo.get_by(Planner.Tasks.DailyPlan, user_id: user.id, day: day) == nil
  end

  defp payload(task, source, target, orders),
    do: %{
      "task_id" => task.id,
      "from" => source,
      "to" => target,
      "orders" => orders
    }
end
