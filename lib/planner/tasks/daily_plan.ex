defmodule Planner.Tasks.DailyPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daily_plans" do
    field :day, :date
    field :used_choices, :integer, default: 0
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(daily_plan, attrs \\ %{}) do
    daily_plan
    |> cast(attrs, [:used_choices])
    |> validate_required([:user_id, :day, :used_choices])
    |> validate_number(:used_choices, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> unique_constraint([:user_id, :day])
    |> foreign_key_constraint(:user_id)
    |> check_constraint(:used_choices, name: :daily_plans_used_choices_range)
  end
end
