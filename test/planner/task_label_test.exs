defmodule Planner.TaskLabelTest do
  use Planner.DataCase

  alias Planner.Tasks.TaskLabel

  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
  import Planner.TasksFixtures

  setup do
    user = user_fixture()
    %{user: user, task: task_fixture(user), label: label_fixture(user)}
  end

  test "a task can have no labels or multiple reusable labels", %{
    user: user,
    task: task,
    label: label
  } do
    assert Repo.preload(task, :labels).labels == []
    another_label = label_fixture(user)
    another_task = task_fixture(user)

    assert {:ok, _} = insert_link(user, task, label)
    assert {:ok, _} = insert_link(user, task, another_label)
    assert {:ok, _} = insert_link(user, another_task, label)

    assert Enum.sort(Enum.map(Repo.preload(task, :labels).labels, & &1.id)) ==
             Enum.sort([label.id, another_label.id])

    assert Enum.sort(Enum.map(Repo.preload(label, :tasks).tasks, & &1.id)) ==
             Enum.sort([task.id, another_task.id])
  end

  test "repeated task and label pairs do not duplicate links", %{
    user: user,
    task: task,
    label: label
  } do
    assert {:ok, _} = insert_link(user, task, label)
    assert {:error, changeset} = insert_link(user, task, label)
    assert errors_on(changeset).task_id == ["has already been taken"]
    assert Repo.aggregate(TaskLabel, :count) == 1
  end

  test "a link cannot point to another owner's task", %{user: user, label: label} do
    other_task = task_fixture(user_fixture())
    assert {:error, changeset} = insert_link(user, other_task, label)
    assert errors_on(changeset).task_id == ["does not exist"]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "a link cannot point to another owner's label", %{user: user, task: task} do
    other_label = label_fixture(user_fixture())
    assert {:error, changeset} = insert_link(user, task, other_label)
    assert errors_on(changeset).label_id == ["does not exist"]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "a link cannot claim ownership of another owner's matching pair", %{
    task: task,
    label: label
  } do
    assert {:error, _} = insert_link(user_fixture(), task, label)
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "nonexistent task and label IDs are rejected", %{user: user, task: task, label: label} do
    assert {:error, changeset} = insert_link(user, %{id: -1}, label)
    assert errors_on(changeset).task_id == ["does not exist"]
    assert {:error, changeset} = insert_link(user, task, %{id: -1})
    assert errors_on(changeset).label_id == ["does not exist"]
    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "all link identities are required", %{user: user, task: task, label: label} do
    for missing <- [:user_id, :task_id, :label_id] do
      link = %TaskLabel{user_id: user.id, task_id: task.id, label_id: label.id}
      changeset = TaskLabel.changeset(Map.put(link, missing, nil), %{})
      assert {:error, invalid} = Repo.insert(changeset)
      assert errors_on(invalid)[missing] == ["can't be blank"]
    end

    assert Repo.aggregate(TaskLabel, :count) == 0
  end

  test "ownership attributes are ignored", %{user: user, task: task, label: label} do
    other = user_fixture()

    for attrs <- [%{user_id: other.id}, %{"user_id" => other.id}] do
      changeset =
        TaskLabel.changeset(
          %TaskLabel{user_id: user.id, task_id: task.id, label_id: label.id},
          attrs
        )

      assert Ecto.Changeset.get_field(changeset, :user_id) == user.id
      assert changeset.valid?
    end
  end

  defp insert_link(user, task, label) do
    %TaskLabel{user_id: user.id}
    |> TaskLabel.changeset(%{task_id: task.id, label_id: label.id})
    |> Repo.insert(mode: :savepoint)
  end
end
