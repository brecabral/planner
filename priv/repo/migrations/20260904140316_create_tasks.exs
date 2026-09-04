defmodule Planner.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :string
      add :scheduled_for, :date
      add :completed_on, :date
      add :kind, :string
      add :label, :string

      timestamps(type: :utc_datetime)
    end
  end
end
