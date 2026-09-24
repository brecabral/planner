defmodule Planner.Labels.Label do
  use Ecto.Schema
  import Ecto.Changeset

  schema "labels" do
    field :name, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(label, attrs) do
    label
    |> cast(attrs, [:name])
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
