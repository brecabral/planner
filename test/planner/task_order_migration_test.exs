defmodule Planner.TaskOrderMigrationTest do
  use Planner.DataCase

  alias Ecto.Adapters.SQL.Sandbox

  test "migration backfills legacy pending lists and preserves today and completed data" do
    Sandbox.unboxed_run(Repo, fn ->
      schema = "ordering_migration_#{System.unique_integer([:positive])}"
      Repo.query!("CREATE SCHEMA #{schema}")
      original_repo = Repo.get_dynamic_repo()

      config =
        Repo.config()
        |> Keyword.merge(
          name: nil,
          pool: DBConnection.ConnectionPool,
          pool_size: 2,
          parameters: [search_path: schema]
        )

      isolated = start_supervised!({Repo, config}, id: make_ref())

      try do
        Repo.put_dynamic_repo(isolated)
        path = Application.app_dir(:planner, "priv/repo/migrations")
        Ecto.Migrator.run(Repo, path, :up, to: 20_261_001_195_014, log: false)

        Repo.query!(
          "INSERT INTO users (id, identifier, inserted_at, updated_at) VALUES (1, 'migration-owner', NOW(), NOW())"
        )

        Repo.query!("""
        INSERT INTO tasks (id, user_id, title, kind, scheduled_for, position, completed_on, inserted_at, updated_at)
        VALUES
          (1, 1, 'later backlog', 'backlog', NULL, NULL, NULL, '2026-01-02', '2026-01-02'),
          (2, 1, 'older backlog', 'backlog', NULL, NULL, NULL, '2026-01-01', '2026-01-01'),
          (3, 1, 'first retry', 'retry', '2026-09-30', NULL, NULL, '2026-01-01', '2026-01-01'),
          (4, 1, 'second retry', 'retry', '2026-09-30', NULL, NULL, '2026-01-01', '2026-01-01'),
          (5, 1, 'today', 'today', '2026-10-01', 1, NULL, '2026-01-01', '2026-01-01'),
          (6, 1, 'completed', 'today', '2026-09-30', NULL, '2026-09-30', '2026-01-01', '2026-01-01')
        """)

        before =
          Repo.query!(
            "SELECT id, user_id, title, kind, scheduled_for, completed_on, inserted_at, updated_at FROM tasks ORDER BY id"
          ).rows

        assert [20_261_009_202_516] =
                 Ecto.Migrator.run(Repo, path, :up, to: 20_261_009_202_516, log: false)

        assert Repo.query!("SELECT id, position FROM tasks ORDER BY id").rows ==
                 [[1, 2], [2, 1], [3, 1], [4, 2], [5, 1], [6, nil]]

        assert Repo.query!(
                 "SELECT id, user_id, title, kind, scheduled_for, completed_on, inserted_at, updated_at FROM tasks ORDER BY id"
               ).rows == before

        for position <- ["NULL", "0", "1"] do
          assert {:error, %Postgrex.Error{}} =
                   Repo.query("UPDATE tasks SET position = #{position} WHERE id = 1")
        end
      after
        Repo.put_dynamic_repo(original_repo)
        Repo.query!("DROP SCHEMA #{schema} CASCADE")
      end
    end)
  end
end
