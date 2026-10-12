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
  Lists the user's completed tasks with labels, newest completion date first.

  IDs descend for tasks completed on the same date. Reads persisted dates without
  recalculating them; the user must be resolved on the server.
  """
  def list_history(%User{id: user_id}) do
    Repo.all(
      from task in Task,
        where: task.user_id == ^user_id and not is_nil(task.completed_on),
        order_by: [desc: task.completed_on, desc: task.id],
        preload: [:labels]
    )
  end

  @doc """
  Completes a current pending task without refunding a daily choice.

  Returns `{:ok, task}` and preserves the original date on repeated completion.
  Missing/foreign/malformed IDs return `{:error, :not_found}`; backlog, retry
  and noncurrent tasks return `{:error, :invalid_state}`. Completion and order
  compaction share the user's transaction. The optional date is server/test
  controlled, never browser input.
  """
  def complete_task(%User{} = user, id, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, _plan ->
        task = owned_task(user, id)

        cond do
          is_nil(task) ->
            {:error, :not_found}

          not is_nil(task.completed_on) ->
            {:ok, task}

          task.kind == :today and task.scheduled_for == day ->
            completed =
              task |> Changeset.change(completed_on: day, position: nil) |> Repo.update!()

            compact_positions(user.id, day)
            {:ok, completed}

          true ->
            {:error, :invalid_state}
        end
      end,
      date
    )
  end

  @doc """
  Reorders exactly the current pending task IDs, leaving the quota unchanged.

  Returns `{:ok, tasks}` in the requested order or `{:error, :invalid_order}`.
  Integer IDs and their string representations are accepted. The complete set
  is reloaded under the user lock, so stale, duplicate, missing and foreign IDs
  are rejected together. The optional date is server/test controlled.
  """
  def reorder_today(%User{} = user, ids, date \\ nil),
    do: reorder_list(user, :today, ids, date)

  @doc "Reorders the complete pending set of one list under the user's lock."
  def reorder_list(%User{} = user, kind, ids, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, _plan ->
        with {:ok, kind} <- list_kind(kind),
             tasks = pending_tasks(user.id, kind, day),
             parsed = parse_order_ids(ids),
             true <- valid_order?(parsed, Enum.map(tasks, & &1.id)) do
          {:ok, persist_order(tasks, parsed)}
        else
          _ -> {:error, :invalid_order}
        end
      end,
      date
    )
  end

  @doc """
  Moves one pending task using complete final orders for the affected lists.
  The server-resolved owner, transition, membership and quota are revalidated
  under the user lock. No browser date or owner is accepted.
  """
  def move_task(user, params, date \\ nil)

  def move_task(
        %User{} = user,
        %{"task_id" => id, "from" => source, "to" => target, "orders" => orders},
        date
      )
      when is_map(orders) do
    UserTransaction.run(
      user,
      fn day, plan ->
        with {:ok, source} <- list_kind(source),
             {:ok, target} <- list_kind(target),
             true <- allowed_move?(source, target),
             %Task{} = task <- owned_task(user, id),
             true <- task.kind == source and is_nil(task.completed_on),
             true <- source != :today or task.scheduled_for == day do
          move_with_orders(task, source, target, orders, day, plan)
        else
          _ -> {:error, :invalid_state}
        end
      end,
      date
    )
  end

  def move_task(%User{}, _params, _date), do: {:error, :invalid_order}

  defp move_with_orders(task, source, target, orders, day, plan) do
    kinds = Enum.uniq([source, target])
    lists = Map.new(kinds, &{&1, pending_tasks(task.user_id, &1, day)})
    parsed = Map.new(kinds, &{&1, parse_order_ids(orders[Atom.to_string(&1)])})

    cond do
      not valid_move_orders?(task.id, target, orders, lists, parsed) ->
        {:error, :invalid_order}

      source != target and target == :today and plan.used_choices >= 3 ->
        {:error, :quota_exhausted}

      true ->
        case transfer_for_move(task, source, target, day, plan) do
          {:error, reason} -> Repo.rollback(reason)
          _ -> :ok
        end

        Enum.each(kinds, fn kind ->
          persist_order(pending_tasks(task.user_id, kind, day), parsed[kind])
        end)

        {:ok, :moved}
    end
  end

  defp valid_move_orders?(task_id, target, orders, lists, parsed) do
    MapSet.new(Map.keys(orders)) == MapSet.new(Map.keys(lists), &Atom.to_string/1) and
      Enum.all?(lists, fn {kind, tasks} ->
        expected = tasks |> Enum.map(& &1.id) |> Enum.reject(&(&1 == task_id))
        expected = if kind == target, do: expected ++ [task_id], else: expected
        valid_order?(parsed[kind], expected)
      end)
  end

  defp transfer_for_move(_task, kind, kind, _day, _plan), do: :ok
  defp transfer_for_move(task, _source, :today, day, plan), do: select_task(task, day, plan)

  defp transfer_for_move(task, source, :backlog, day, plan) when source in [:today, :retry],
    do: return_task(task, day, plan)

  defp list_kind(kind) when kind in [:today, :backlog, :retry], do: {:ok, kind}
  defp list_kind("today"), do: {:ok, :today}
  defp list_kind("backlog"), do: {:ok, :backlog}
  defp list_kind("retry"), do: {:ok, :retry}
  defp list_kind(_), do: :error

  defp allowed_move?(kind, kind), do: true
  defp allowed_move?(source, :today) when source in [:backlog, :retry], do: true
  defp allowed_move?(source, :backlog) when source in [:today, :retry], do: true
  defp allowed_move?(_, _), do: false

  defp valid_order?(ids, expected) do
    is_list(ids) and length(ids) == length(expected) and
      MapSet.new(ids) == MapSet.new(expected)
  end

  defp pending_tasks(user_id, kind, day) do
    query =
      from task in Task,
        where: task.user_id == ^user_id and task.kind == ^kind and is_nil(task.completed_on),
        order_by: [task.position, task.id]

    query =
      if kind == :today, do: from(task in query, where: task.scheduled_for == ^day), else: query

    Repo.all(query)
  end

  defp next_position(user_id, kind, day) do
    pending_tasks(user_id, kind, day)
    |> Enum.map(& &1.position)
    |> Enum.max(fn -> 0 end)
    |> Kernel.+(1)
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
  Returns a pending today/retry task to backlog atomically.
  Only a current today task refunds a choice; retry preserves the quota.

  Returns `{:ok, task}`; an already pending backlog task is an unchanged success.
  Missing/foreign/malformed IDs return `{:error, :not_found}` and completed,
  noncurrent tasks return `{:error, :invalid_state}`. Persistence
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
          task.kind == :retry -> return_task(task, day, plan)
          task.kind == :today and task.scheduled_for == day -> return_task(task, day, plan)
          true -> {:error, :invalid_state}
        end
      end,
      date
    )
  end

  defp return_task(task, day, plan) do
    with {:ok, returned} <-
           task
           |> Changeset.change(
             kind: :backlog,
             position: next_position(task.user_id, :backlog, day)
           )
           |> Repo.update() do
      compact_positions(task.user_id, day, task.kind)

      refund_return(task, returned, plan)
    end
  end

  defp refund_return(%Task{kind: :retry}, returned, _plan), do: {:ok, returned}

  defp refund_return(_task, returned, plan) do
    case plan |> DailyPlan.changeset(%{used_choices: plan.used_choices - 1}) |> Repo.update() do
      {:ok, _plan} -> {:ok, returned}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp compact_positions(user_id, day, kind \\ :today) do
    tasks = pending_tasks(user_id, kind, day)
    persist_order(tasks, Enum.map(tasks, & &1.id))
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
      compact_positions(task.user_id, day, task.kind)
      {:ok, selected}
    end
  end

  @doc """
  Returns the normalized planning collections and persisted daily quota.

  The result is `{:ok, snapshot}` with `day`, `used_choices`, `available_choices`,
  `backlog`, `today` and `retry`. Tasks include their labels; completed tasks are
  excluded. All pending lists use their persisted positions. All reads share
  the user's transaction lock.

  The optional date is for controlled server-side calls/tests, never browser input.
  """
  def snapshot(%User{id: user_id} = user, date \\ nil) do
    UserTransaction.run(
      user,
      fn day, plan ->
        pending = from task in Task, where: task.user_id == ^user_id and is_nil(task.completed_on)
        ordered_pending = from task in pending, order_by: [task.position, task.id]

        {:ok,
         %{
           day: day,
           used_choices: plan.used_choices,
           available_choices: 3 - plan.used_choices,
           backlog:
             Repo.all(
               from task in ordered_pending, where: task.kind == :backlog, preload: [:labels]
             ),
           retry:
             Repo.all(
               from task in ordered_pending, where: task.kind == :retry, preload: [:labels]
             ),
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
      lock_registration_owner!(user, attrs)
      position = next_position(user.id, :backlog, nil)

      case user
           |> change_task(attrs)
           |> Changeset.put_change(:position, position)
           |> Repo.insert() do
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

  defp lock_registration_owner!(user, attrs) do
    if is_nil(user.id) do
      rollback_input(user, attrs, :user_id)
    end

    UserTransaction.lock(user)
  rescue
    Ecto.NoResultsError -> rollback_input(user, attrs, :user_id)
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
