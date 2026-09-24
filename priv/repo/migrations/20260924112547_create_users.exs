defmodule Planner.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :identifier, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:identifier])
  end
end
