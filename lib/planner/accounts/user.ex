defmodule Planner.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :identifier, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:identifier])
    |> validate_required([:identifier])
    |> unique_constraint(:identifier)
  end
end
