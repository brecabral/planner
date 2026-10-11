defmodule Planner.Repo.Migrations.OrderPendingLists do
  use Ecto.Migration

  def up do
    execute """
    WITH ordered AS (
      SELECT id, row_number() OVER (
        PARTITION BY user_id, kind ORDER BY inserted_at, id
      ) AS position
      FROM tasks WHERE kind IN ('backlog', 'retry') AND completed_on IS NULL
    )
    UPDATE tasks SET position = ordered.position FROM ordered WHERE tasks.id = ordered.id
    """

    create constraint(:tasks, :tasks_pending_requires_position,
             check: "completed_on IS NOT NULL OR position IS NOT NULL"
           )

    create unique_index(:tasks, [:user_id, :kind, :position],
             name: :tasks_pending_lists_position_unique,
             where: "kind IN ('backlog', 'retry') AND completed_on IS NULL"
           )
  end

  def down do
    drop index(:tasks, [:user_id, :kind, :position], name: :tasks_pending_lists_position_unique)
    drop constraint(:tasks, :tasks_pending_requires_position)

    execute "UPDATE tasks SET position = NULL WHERE kind IN ('backlog', 'retry') AND completed_on IS NULL"
  end
end
