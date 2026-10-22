defmodule Planner.Themes do
  @moduledoc """
  Owns the application theme catalog, free entitlements and account selection.
  """
  import Ecto.Query
  alias Planner.Accounts.{Scope, User}
  alias Planner.Repo
  alias Planner.Themes.{Entitlement, Theme}

  @free_codes ["planner", "planner_dark"]

  @doc "Prepares a server-owned account idempotently without resetting its selection."
  def prepare_user(%User{id: id, email: email}) when is_binary(email) do
    Repo.transact(fn ->
      case lock_account(id) do
        %User{} = user ->
          now = DateTime.utc_now(:second)

          entries =
            Enum.map(
              @free_codes,
              &%{user_id: id, theme_code: &1, origin: "free", inserted_at: now, updated_at: now}
            )

          Repo.insert_all(Entitlement, entries,
            on_conflict: :nothing,
            conflict_target: [:user_id, :theme_code]
          )

          {:ok, user}

        nil ->
          {:error, :unauthenticated}
      end
    end)
  end

  def prepare_user(_), do: {:error, :unauthenticated}

  @doc "Lists the authenticated account's granted themes in stable code order."
  def list_available_themes(%Scope{user: %User{id: id, email: email}}) when is_binary(email) do
    Repo.all(
      from t in Theme,
        join: e in Entitlement,
        on: e.theme_code == t.code,
        where: e.user_id == ^id,
        order_by: t.code
    )
  end

  def list_available_themes(_), do: []

  @doc "Selects a granted theme, taking ownership exclusively from the server scope."
  def select_theme(%Scope{user: %User{id: id, email: email}}, attrs) when is_binary(email) do
    case attrs do
      %{"theme_code" => code} when map_size(attrs) == 1 and is_binary(code) ->
        Repo.transact(fn -> persist_selection(id, code) end)

      _ ->
        {:error, :invalid_selection}
    end
  rescue
    Postgrex.Error -> {:error, :persistence_failed}
  end

  def select_theme(_, _), do: {:error, :unauthenticated}

  defp persist_selection(id, code) do
    with %User{} = user <- lock_account(id),
         true <-
           Repo.exists?(
             from e in Entitlement,
               where: e.user_id == ^id and e.theme_code == ^code
           ) do
      user |> Ecto.Changeset.change(theme_code: code) |> Repo.update()
    else
      nil -> {:error, :unauthenticated}
      false -> {:error, :unavailable_theme}
    end
  end

  defp lock_account(id) do
    Repo.one(from u in User, where: u.id == ^id and not is_nil(u.email), lock: "FOR UPDATE")
  end
end
