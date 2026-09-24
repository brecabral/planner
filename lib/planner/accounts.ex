defmodule Planner.Accounts do
  @moduledoc """
  Prepares and resolves the persistent default user.
  """

  alias Planner.Accounts.User
  alias Planner.Repo

  @default_identifier "default"

  @doc """
  Creates the default user if absent, preserving any existing user data.
  """
  def ensure_default_user! do
    %User{}
    |> User.changeset(%{identifier: @default_identifier})
    |> Repo.insert!(on_conflict: :nothing, conflict_target: :identifier)

    get_default_user!()
  end

  @doc """
  Returns the persisted default user, raising if data has not been prepared.
  """
  def get_default_user! do
    Repo.get_by!(User, identifier: @default_identifier)
  end
end
