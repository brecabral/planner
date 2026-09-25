defmodule Planner.Tasks do
  @moduledoc """
  Provides task registration and queries for an explicitly resolved server-side user.
  """

  import Ecto.Query, warn: false

  alias Planner.Accounts.User
  alias Planner.Repo
  alias Planner.Tasks.Task

  @doc """
  Lists owned tasks by creation time, breaking ties by ID.
  """
  def list_tasks(%User{id: user_id}) do
    Repo.all(
      from task in Task,
        where: task.user_id == ^user_id,
        order_by: [task.inserted_at, task.id]
    )
  end

  @doc """
  Gets an owned task, raising for missing or foreign tasks.
  """
  def get_task!(%User{id: user_id}, id) do
    Repo.get_by!(Task, id: id, user_id: user_id)
  end

  @doc """
  Registers a backlog task, accepting only its title from attributes.
  """
  def create_task(%User{} = user, attrs \\ %{}) do
    user
    |> change_task(attrs)
    |> Repo.insert()
  end

  @doc """
  Builds a changeset for registering a new task owned by the supplied user.
  """
  def change_task(%User{id: user_id}, attrs \\ %{}) do
    %Task{user_id: user_id, kind: :backlog}
    |> Task.changeset(attrs)
  end
end
