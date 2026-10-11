defmodule Planner.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :text, null: false
      add :kind, :string
      add :scheduled_for, :date
      add :position, :integer
      add :completed_on, :date
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:user_id])
  end
end
