defmodule Planner.UserTransaction do
  @moduledoc """
  Serializes planning operations for one server-resolved user.
  """

  import Ecto.Query

  alias Planner.Accounts.User
  alias Planner.Day
  alias Planner.Repo
  alias Planner.Tasks.DailyPlan
  alias Planner.Tasks.Task

  @doc """
  Runs an operation with a coherent day and its persisted quota under a user lock.

  Before invoking the operation, expired pending tasks become retry and lose
  their positions. Their selection date, identity and completion data remain
  unchanged. Normalization is rolled back together with a rejected operation.

  The operation receives `(day, daily_plan)` and returns `{:ok, value}` or
  `{:error, reason}`. An error rolls back all writes, including quota creation;
  exceptions also roll back and propagate to the caller. Operations must scope
  their queries to the supplied user and perform all writes in this callback.

  The user row is locked before reading the date or quota, including when no
  quota exists yet. The default date comes from `Planner.Day.current/0` after
  acquiring that lock. The optional `Date` reuses `Planner.Day.current/1` for
  deterministic server-side tests; never pass browser parameters as the date.

  This boundary does not select tasks or expose quota CRUD. Planning contexts
  implement their commands inside the callback and reuse the captured day.
  """
  def run(%User{id: user_id}, operation, date \\ nil) when is_function(operation, 2) do
    Repo.transaction(fn ->
      Repo.one!(from user in User, where: user.id == ^user_id, lock: "FOR UPDATE")
      day = if is_nil(date), do: Day.current(), else: Day.current(date)
      plan = get_or_create_plan!(user_id, day)
      normalize_expired_tasks(user_id, day)

      case operation.(day, plan) do
        {:ok, value} -> value
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp normalize_expired_tasks(user_id, day) do
    Repo.update_all(
      from(task in Task,
        where:
          task.user_id == ^user_id and task.kind == :today and
            is_nil(task.completed_on) and task.scheduled_for < ^day
      ),
      set: [kind: :retry, position: nil, updated_at: DateTime.utc_now(:second)]
    )
  end

  defp get_or_create_plan!(user_id, day) do
    Repo.get_by(DailyPlan, user_id: user_id, day: day) ||
      %DailyPlan{user_id: user_id, day: day}
      |> DailyPlan.changeset()
      |> Repo.insert!()
  end
end
