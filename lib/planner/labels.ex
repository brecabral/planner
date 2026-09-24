defmodule Planner.Labels do
  @moduledoc """
  Provides the label catalog for an explicitly resolved server-side user.
  """

  import Ecto.Query, warn: false

  alias Planner.Accounts.User
  alias Planner.Labels.Label
  alias Planner.Repo

  @doc """
  Lists only labels owned by the supplied user.
  """
  def list_labels(%User{id: user_id}) do
    Repo.all(from label in Label, where: label.user_id == ^user_id, order_by: label.id)
  end

  @doc """
  Gets an owned label, raising for missing or foreign labels.
  """
  def get_label!(%User{id: user_id}, id) do
    Repo.get_by!(Label, id: id, user_id: user_id)
  end

  @doc """
  Creates a label for the server-side user, ignoring ownership in attributes.

  This operation joins the caller's repository transaction; it does not start
  an independent transaction. Callers must roll back their transaction when
  another part of a composed operation fails.
  """
  def create_label(%User{id: user_id}, attrs \\ %{}) do
    %Label{user_id: user_id}
    |> Label.changeset(attrs)
    |> Repo.insert()
  end
end
