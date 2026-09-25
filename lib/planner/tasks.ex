defmodule Planner.Tasks do
  @moduledoc """
  Provides task registration and queries for an explicitly resolved server-side user.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias Planner.Accounts.User
  alias Planner.Labels
  alias Planner.Labels.Label
  alias Planner.Repo
  alias Planner.Tasks.Task
  alias Planner.Tasks.TaskLabel

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
  Registers a backlog task with optional owned label IDs and new label names.

  `label_ids` and `new_label_names` accept lists under atom or string keys.
  The task, newly created labels and links are committed together. Errors in
  label input are reported on the corresponding field of the task changeset.
  """
  def create_task(%User{} = user, attrs \\ %{}) do
    Repo.transaction(fn ->
      case user |> change_task(attrs) |> Repo.insert() do
        {:ok, task} ->
          existing_ids = owned_label_ids!(user, attrs)
          new_ids = create_new_label_ids!(user, attrs)
          insert_links!(user, task, existing_ids ++ new_ids, attrs)
          task

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Builds a changeset for registering a new task owned by the supplied user.
  """
  def change_task(%User{id: user_id}, attrs \\ %{}) do
    %Task{user_id: user_id, kind: :backlog}
    |> Task.changeset(attrs)
  end

  defp owned_label_ids!(user, attrs) do
    ids = input(attrs, :label_ids)

    unless is_list(ids) do
      rollback_input(user, attrs, :label_ids)
    end

    parsed_ids = Enum.map(ids, &parse_label_id/1)

    if Enum.any?(parsed_ids, &is_nil/1) do
      rollback_input(user, attrs, :label_ids)
    end

    distinct_ids = Enum.uniq(parsed_ids)

    owned_count =
      Repo.aggregate(
        from(label in Label,
          where: label.user_id == ^user.id and label.id in ^distinct_ids
        ),
        :count
      )

    if owned_count != length(distinct_ids) do
      rollback_input(user, attrs, :label_ids)
    end

    distinct_ids
  end

  defp parse_label_id(id) when is_integer(id), do: id

  defp parse_label_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {parsed, ""} -> parsed
      _ -> nil
    end
  end

  defp parse_label_id(_), do: nil

  defp create_new_label_ids!(user, attrs) do
    names = input(attrs, :new_label_names)

    unless is_list(names) do
      rollback_input(user, attrs, :new_label_names)
    end

    Enum.map(names, fn name ->
      case Labels.create_label(user, %{name: name}) do
        {:ok, label} -> label.id
        {:error, _changeset} -> rollback_input(user, attrs, :new_label_names)
      end
    end)
  end

  defp insert_links!(user, task, label_ids, attrs) do
    Enum.each(label_ids, fn label_id ->
      result =
        %TaskLabel{user_id: user.id}
        |> TaskLabel.changeset(%{task_id: task.id, label_id: label_id})
        |> Repo.insert()

      case result do
        {:ok, _link} -> :ok
        {:error, _changeset} -> rollback_input(user, attrs, :label_ids)
      end
    end)
  end

  defp input(attrs, key), do: Map.get(attrs, key, Map.get(attrs, Atom.to_string(key), []))

  defp rollback_input(user, attrs, field) do
    user
    |> change_task(attrs)
    |> Changeset.add_error(field, "is invalid")
    |> Repo.rollback()
  end
end
