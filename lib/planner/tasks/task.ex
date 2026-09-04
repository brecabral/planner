defmodule Planner.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :name, :string
    field :scheduled_for, :date
    field :completed_on, :date
    field :kind, Ecto.Enum, values: [:action, :commitment]
    field :label, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :scheduled_for, :completed_on, :kind, :label])
    |> validate_required([:name, :scheduled_for, :completed_on, :kind, :label])
  end
end
