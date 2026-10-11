defmodule Planner.Repo.Migrations.ConstrainTodayPositions do
  use Ecto.Migration

  def change do
    create constraint(:tasks, :tasks_position_positive, check: "position IS NULL OR position > 0")

    create constraint(:tasks, :tasks_today_requires_position_and_date,
             check:
               "kind <> 'today' OR completed_on IS NOT NULL OR " <>
                 "(position IS NOT NULL AND scheduled_for IS NOT NULL)"
           )

    create unique_index(:tasks, [:user_id, :scheduled_for, :position],
             name: :tasks_pending_today_position_unique,
             where: "kind = 'today' AND completed_on IS NULL"
           )
  end
end
