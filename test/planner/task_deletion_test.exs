defmodule Planner.TaskDeletionTest do
  use Planner.DataCase

  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
  import Planner.TasksFixtures

  alias Planner.Labels.Label
  alias Planner.Tasks
  alias Planner.Tasks.DailyPlan
  alias Planner.Tasks.Task
  alias Planner.Tasks.TaskLabel

  @day ~D[2026-10-02]

  for kind <- [:backlog, :retry, :today] do
    @tag kind: kind
    test "deleting #{kind} removes links, preserves labels and compacts positions", %{kind: kind} do
      user = user_fixture()
      label = label_fixture(user)

      [first, moving, last] =
        tasks = for _ <- 1..3, do: task_fixture(user, %{label_ids: [label.id]})

      if kind != :backlog do
        day = if kind == :retry, do: Date.add(@day, -1), else: @day
        for task <- tasks, do: assert({:ok, _} = Tasks.select_today(user, task.id, day))
      end

      if kind != :today do
        for _ <- 1..3 do
          task = task_fixture(user)
          assert {:ok, _} = Tasks.select_today(user, task.id, @day)
        end
      end

      assert {:ok, deleted} = Tasks.delete_pending_task(user, to_string(moving.id), @day)
      assert deleted.id == moving.id
      assert Repo.get(Task, moving.id) == nil
      assert Repo.all(from link in TaskLabel, where: link.task_id == ^moving.id) == []
      assert Repo.get!(Label, label.id) == label
      assert {:ok, snapshot} = Tasks.snapshot(user, @day)
      assert Enum.map(snapshot[kind], &{&1.id, &1.position}) == [{first.id, 1}, {last.id, 2}]
      assert Enum.all?(snapshot[kind], &(&1.labels == [label]))
      assert snapshot.used_choices == if(kind == :today, do: 2, else: 3)
      assert {:error, :not_found} = Tasks.delete_pending_task(user, moving.id, @day)
      assert {:ok, ^snapshot} = Tasks.snapshot(user, @day)
    end
  end

  test "unavailable IDs share one error and preserve history, links and quota" do
    user = user_fixture()
    completed = task_fixture(user, %{new_label_names: ["History"]})
    assert {:ok, _} = Tasks.select_today(user, completed.id, @day)
    assert {:ok, _} = Tasks.complete_task(user, completed.id, @day)
    foreign = task_fixture(user_fixture())
    history = Tasks.list_history(user)
    assert {:ok, before} = Tasks.snapshot(user, @day)

    for id <- [nil, "invalid", -1, foreign.id, completed.id] do
      assert {:error, :not_found} = Tasks.delete_pending_task(user, id, @day)
      assert {:ok, ^before} = Tasks.snapshot(user, @day)
      assert Tasks.list_history(user) == history
    end

    assert Repo.get!(Task, foreign.id) == foreign
  end

  test "deletion after rollover does not refund the new day and uses the server day by default" do
    user = user_fixture()
    expired = task_fixture(user)
    assert {:ok, _} = Tasks.select_today(user, expired.id, Date.add(@day, -1))
    assert {:ok, _} = Tasks.delete_pending_task(user, expired.id, @day)

    assert {:ok, %{used_choices: 0, retry: [], today: [], backlog: []}} =
             Tasks.snapshot(user, @day)

    assert Repo.get_by!(DailyPlan, user_id: user.id, day: Date.add(@day, -1)).used_choices == 1
    task = task_fixture(user)
    assert {:ok, _} = Tasks.delete_pending_task(user, task.id)
    assert Repo.get(Task, task.id) == nil
  end

  test "failed refund rolls back deletion, links and compacted positions" do
    user = user_fixture()
    [moving, other] = for _ <- 1..2, do: task_fixture(user, %{new_label_names: ["Keep"]})
    for task <- [moving, other], do: assert({:ok, _} = Tasks.select_today(user, task.id, @day))
    assert {:ok, before} = Tasks.snapshot(user, @day)
    links = Repo.all(TaskLabel)

    Repo.query!(
      "ALTER TABLE daily_plans ADD CONSTRAINT reject_delete_refund CHECK (used_choices = 2) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn -> Tasks.delete_pending_task(user, moving.id, @day) end
    assert {:ok, ^before} = Tasks.snapshot(user, @day)
    assert Repo.all(TaskLabel) == links
  end

  test "failed compaction restores deletion, links, rollover and new quota creation" do
    user = user_fixture()
    [moving, expired] = for _ <- 1..2, do: task_fixture(user, %{new_label_names: ["Keep"]})

    for task <- [moving, expired],
        do: assert({:ok, _} = Tasks.select_today(user, task.id, Date.add(@day, -1)))

    before = Tasks.list_tasks(user)
    links = Repo.all(TaskLabel)

    Repo.query!(
      "ALTER TABLE tasks ADD CONSTRAINT reject_delete_compaction CHECK (id != #{expired.id} OR kind != 'retry' OR position = 2) NOT VALID"
    )

    assert_raise Ecto.ConstraintError, fn -> Tasks.delete_pending_task(user, moving.id, @day) end
    assert Tasks.list_tasks(user) == before
    assert Repo.all(TaskLabel) == links
    assert Repo.get_by(DailyPlan, user_id: user.id, day: @day) == nil
  end
end
