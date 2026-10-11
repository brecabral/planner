defmodule Planner.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  isolated user identities without global seeds.
  """

  alias Planner.Accounts.User
  alias Planner.Repo

  @doc """
  Generate a unique user identifier.
  """
  def unique_user_identifier, do: "some identifier#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    %User{}
    |> User.changeset(Enum.into(attrs, %{identifier: unique_user_identifier()}))
    |> Repo.insert!()
  end
end
