defmodule Planner.TasksTest do
  use Planner.DataCase

  alias Ecto.Adapters.SQL
  alias Planner.Labels
  alias Planner.Labels.Label
  alias Planner.Tasks
  alias Planner.Tasks.Task
  alias Planner.Tasks.TaskLabel

  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
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
