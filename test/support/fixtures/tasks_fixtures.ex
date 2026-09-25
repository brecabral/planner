defmodule Planner.TasksFixtures do
  @moduledoc """
  Creates backlog tasks for an explicit test user.
  """

  @doc """
  Generates a task owned by the supplied user.
  """
  def task_fixture(user, attrs \\ %{}) do
    {:ok, task} = Planner.Tasks.create_task(user, Enum.into(attrs, %{title: "some title"}))
    task
  end
end
