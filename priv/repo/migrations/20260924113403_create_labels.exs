defmodule Planner.Repo.Migrations.CreateLabels do
  use Ecto.Migration

  def change do
    create table(:labels) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:labels, [:user_id])
  end
end
