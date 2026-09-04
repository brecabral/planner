defmodule Planner.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Planner.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        completed_on: ~D[2026-09-03],
        kind: :action,
        label: "some label",
        name: "some name",
        scheduled_for: ~D[2026-09-03]
      })
      |> Planner.Tasks.create_task()

    task
  end
end
