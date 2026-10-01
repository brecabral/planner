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
  alias Planner.Tasks.DailyPlan
  alias Planner.Tasks.Task
  alias Planner.Tasks.TaskLabel
  alias Planner.UserTransaction

  @doc """
  Reorders exactly the current pending task IDs, leaving the quota unchanged.

  Returns `{:ok, tasks}` in the requested order or `{:error, :invalid_order}`.
  Integer IDs and their string representations are accepted. The complete set
  is reloaded under the user lock, so stale, duplicate, missing and foreign IDs
  are rejected together. The optional date is server/test controlled.
  """
  def reorder_today(%User{id: user_id} = user, ids, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, _plan ->
        tasks =
          Repo.all(
            from task in Task,
              where:
                task.user_id == ^user_id and task.kind == :today and
                  task.scheduled_for == ^day and is_nil(task.completed_on),
              order_by: [task.position, task.id]
          )

        parsed_ids = parse_order_ids(ids)

        if is_list(parsed_ids) and length(parsed_ids) == length(tasks) and
             MapSet.new(parsed_ids) == MapSet.new(tasks, & &1.id) do
          {:ok, persist_order(tasks, parsed_ids)}
        else
          {:error, :invalid_order}
        end
      end,
      date
    )
  end

  defp parse_order_ids(ids) when is_list(ids) do
    Enum.map(ids, fn id ->
      case Ecto.Type.cast(:id, id) do
        {:ok, id} when is_integer(id) -> id
        _ -> nil
      end
    end)
  end

  defp parse_order_ids(_), do: nil

  defp persist_order(tasks, ids) do
    offset = Enum.max(Enum.map(tasks, & &1.position), fn -> 0 end) + 1

    # Vacate the target range without violating the immediate unique index.
    staged =
      tasks
      |> Enum.with_index(offset)
      |> Map.new(fn {task, position} ->
        updated = task |> Changeset.change(position: position) |> Repo.update!()
        {updated.id, updated}
      end)

    ids
    |> Enum.with_index(1)
    |> Enum.map(fn {id, position} ->
      staged |> Map.fetch!(id) |> Changeset.change(position: position) |> Repo.update!()
    end)
  end

  @doc """
  Returns a current pending task to backlog and refunds one choice atomically.

  Returns `{:ok, task}`; an already pending backlog task is an unchanged success.
  Missing/foreign/malformed IDs return `{:error, :not_found}` and completed,
  retry or noncurrent tasks return `{:error, :invalid_state}`. Persistence
  errors roll back the task, remaining positions and quota together.
  The optional date is server/test controlled, never browser input.
  """
  def return_to_backlog(%User{} = user, id, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, plan ->
        task = owned_task(user, id)

        cond do
          is_nil(task) -> {:error, :not_found}
          not is_nil(task.completed_on) -> {:error, :invalid_state}
          task.kind == :backlog -> {:ok, task}
          task.kind == :today and task.scheduled_for == day -> return_task(task, day, plan)
          true -> {:error, :invalid_state}
        end
      end,
      date
    )
  end

  defp return_task(task, day, plan) do
    with {:ok, returned} <-
           task |> Changeset.change(kind: :backlog, position: nil) |> Repo.update() do
      compact_positions(task.user_id, day)

      case plan |> DailyPlan.changeset(%{used_choices: plan.used_choices - 1}) |> Repo.update() do
        {:ok, _plan} -> {:ok, returned}
        {:error, changeset} -> {:error, changeset}
      end
    end
  end

  defp compact_positions(user_id, day) do
    Repo.all(
      from task in Task,
        where:
          task.user_id == ^user_id and task.kind == :today and
            task.scheduled_for == ^day and is_nil(task.completed_on),
        order_by: [task.position, task.id]
    )
    |> Enum.with_index(1)
    |> Enum.each(fn {task, position} ->
      task |> Changeset.change(position: position) |> Repo.update!()
    end)
  end

  @doc """
  Selects an owned backlog/retry task for today and consumes one daily choice.

  Returns `{:ok, task}` or `{:error, :not_found | :invalid_state | :quota_exhausted}`.
  Selecting a current pending task again succeeds without consuming another choice.
  Missing, foreign and malformed IDs have the same result. The optional date is
  controlled by the server/tests, never browser input. All state is reloaded after
  acquiring the user's lock and normalizing expired tasks.
  """
  def select_today(%User{} = user, id, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, plan ->
        task = owned_task(user, id)

        cond do
          is_nil(task) -> {:error, :not_found}
          not is_nil(task.completed_on) -> {:error, :invalid_state}
          task.kind == :today and task.scheduled_for == day -> {:ok, task}
          task.kind not in [:backlog, :retry] -> {:error, :invalid_state}
          plan.used_choices >= 3 -> {:error, :quota_exhausted}
          true -> select_task(task, day, plan)
        end
      end,
      date
    )
  end

  defp owned_task(user, id) do
    case Ecto.Type.cast(:id, id) do
      {:ok, id} when is_integer(id) -> Repo.get_by(Task, id: id, user_id: user.id)
      _ -> nil
    end
  end

  defp select_task(task, day, plan) do
    last_position =
      Repo.aggregate(
        from(t in Task,
          where:
            t.user_id == ^task.user_id and t.kind == :today and
              t.scheduled_for == ^day and is_nil(t.completed_on)
        ),
        :max,
        :position
      ) || 0

    with {:ok, selected} <-
           task
           |> Changeset.change(kind: :today, scheduled_for: day, position: last_position + 1)
           |> Repo.update(),
         {:ok, _plan} <-
           plan |> DailyPlan.changeset(%{used_choices: plan.used_choices + 1}) |> Repo.update() do
      {:ok, selected}
    end
  end

  @doc """
  Returns the normalized planning collections and persisted daily quota.

  The result is `{:ok, snapshot}` with `day`, `used_choices`, `available_choices`,
  `backlog`, `today` and `retry`. Tasks include their labels; completed tasks are
  excluded. Backlog and retry use creation order with ID as a tie-breaker, while
  today's tasks use their positions. All reads share the user's transaction lock.

  The optional date is for controlled server-side calls/tests, never browser input.
  """
  def snapshot(%User{id: user_id} = user, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, plan ->
        pending = from task in Task, where: task.user_id == ^user_id and is_nil(task.completed_on)
        creation_order = from task in pending, order_by: [task.inserted_at, task.id]

        {:ok,
         %{
           day: day,
           used_choices: plan.used_choices,
           available_choices: 3 - plan.used_choices,
           backlog:
             Repo.all(
               from task in creation_order, where: task.kind == :backlog, preload: [:labels]
             ),
           retry:
             Repo.all(from task in creation_order, where: task.kind == :retry, preload: [:labels]),
           today:
             Repo.all(
               from task in pending,
                 where: task.kind == :today and task.scheduled_for == ^day,
                 order_by: [task.position, task.id],
                 preload: [:labels]
             )
         }}
      end,
      date
    )
  end

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
