defmodule Planner.Tasks.TaskLabel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_labels" do
    field :task_id, :id
    field :label_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_label, attrs) do
    task_label
    |> cast(attrs, [:task_id, :label_id])
    |> validate_required([:task_id, :label_id, :user_id])
    |> unique_constraint([:task_id, :label_id])
    |> foreign_key_constraint(:task_id)
    |> foreign_key_constraint(:label_id)
    |> foreign_key_constraint(:user_id)
  end
end
