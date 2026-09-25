defmodule Planner.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :kind, Ecto.Enum, values: [:backlog, :today, :retry]
    field :scheduled_for, :date
    field :position, :integer
    field :completed_on, :date
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title])
    |> update_change(:title, &String.trim/1)
    |> validate_required([:title, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
