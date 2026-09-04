defmodule Planner.TasksTest do
  use Planner.DataCase

  alias Planner.Tasks

  describe "tasks" do
    alias Planner.Tasks.Task

    import Planner.TasksFixtures

    @invalid_attrs %{label: nil, name: nil, kind: nil, scheduled_for: nil, completed_on: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{label: "some label", name: "some name", kind: :action, scheduled_for: ~D[2026-09-03], completed_on: ~D[2026-09-03]}

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.label == "some label"
      assert task.name == "some name"
      assert task.kind == :action
      assert task.scheduled_for == ~D[2026-09-03]
      assert task.completed_on == ~D[2026-09-03]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{label: "some updated label", name: "some updated name", kind: :commitment, scheduled_for: ~D[2026-09-04], completed_on: ~D[2026-09-04]}

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.label == "some updated label"
      assert task.name == "some updated name"
      assert task.kind == :commitment
      assert task.scheduled_for == ~D[2026-09-04]
      assert task.completed_on == ~D[2026-09-04]
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
