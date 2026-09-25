defmodule Planner.TasksTest do
  use Planner.DataCase

  alias Planner.Tasks
  alias Planner.Tasks.Task

  import Planner.AccountsFixtures
  import Planner.TasksFixtures

  setup do
    %{user: user_fixture()}
  end

  test "create_task/2 creates distinct backlog tasks from trimmed titles", %{user: user} do
    assert {:ok, %Task{} = task} = Tasks.create_task(user, %{title: "  some title  "})
    assert task.title == "some title"
    assert task.user_id == user.id
    assert task.kind == :backlog
    assert is_nil(task.scheduled_for)
    assert is_nil(task.completed_on)
    assert is_nil(task.position)
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
end
