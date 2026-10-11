defmodule Planner.Repo.Migrations.CreateDailyPlans do
  use Ecto.Migration

  def change do
    create table(:daily_plans) do
      add :day, :date, null: false
      add :used_choices, :integer, default: 0, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:daily_plans, [:user_id, :day])

    create constraint(:daily_plans, :daily_plans_used_choices_range,
             check: "used_choices >= 0 AND used_choices <= 3"
           )
  end
end
