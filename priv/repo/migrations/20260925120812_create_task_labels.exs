defmodule Planner.Repo.Migrations.CreateTaskLabels do
  use Ecto.Migration

  def change do
    create unique_index(:tasks, [:id, :user_id])
    create unique_index(:labels, [:id, :user_id])

    create table(:task_labels) do
      add :user_id, references(:users, on_delete: :nothing), null: false

      add :task_id, references(:tasks, with: [user_id: :user_id], on_delete: :nothing),
        null: false

      add :label_id, references(:labels, with: [user_id: :user_id], on_delete: :nothing),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:task_labels, [:task_id, :label_id])
    create index(:task_labels, [:label_id])
    create index(:task_labels, [:user_id])
  end
end
