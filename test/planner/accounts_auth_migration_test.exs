defmodule Planner.AccountsAuthMigrationTest do
  use Planner.DataCase, async: false
  alias Ecto.Adapters.SQL.Sandbox
  alias Planner.Accounts

  test "additive auth migration preserves legacy identity, ownership, history and quota" do
    Sandbox.unboxed_run(Repo, fn ->
      schema = "auth_migration_#{System.unique_integer([:positive])}"
      Repo.query!("CREATE SCHEMA #{schema}")
      original_repo = Repo.get_dynamic_repo()

      config =
        Repo.config()
        |> Keyword.merge(
          name: nil,
          pool: DBConnection.ConnectionPool,
          pool_size: 2,
          parameters: [search_path: "#{schema},public"]
        )

      isolated = start_supervised!({Repo, config}, id: make_ref())

      migrations = auth_migrations()

      try do
        Repo.put_dynamic_repo(isolated)

        Ecto.Migrator.run(Repo, migrations, :up,
          to: 20_261_009_202_516,
          prefix: schema,
          log: false
        )

        Repo.query!(
          "INSERT INTO users (identifier, inserted_at, updated_at) VALUES ('default', NOW(), NOW())"
        )

        Repo.query!("""
        INSERT INTO tasks (user_id, title, kind, scheduled_for, position, completed_on, inserted_at, updated_at)
        VALUES (1, 'pending legacy task', 'backlog', NULL, 1, NULL, NOW(), NOW()),
               (1, 'legacy history', 'today', '2026-10-01', NULL, '2026-10-01', NOW(), NOW())
        """)

        Repo.query!(
          "INSERT INTO labels (user_id, name, inserted_at, updated_at) VALUES (1, 'legacy label', NOW(), NOW())"
        )

        Repo.query!(
          "INSERT INTO task_labels (user_id, task_id, label_id, inserted_at, updated_at) VALUES (1, 1, 1, NOW(), NOW())"
        )

        Repo.query!(
          "INSERT INTO daily_plans (user_id, day, used_choices, inserted_at, updated_at) VALUES (1, '2026-10-01', 2, NOW(), NOW())"
        )

        tables = ["tasks", "labels", "task_labels", "daily_plans"]
        before = Map.new(tables, &{&1, Repo.query!("SELECT * FROM #{&1} ORDER BY id").rows})
        legacy = Repo.query!("SELECT id, identifier, inserted_at, updated_at FROM users").rows

        assert [20_261_012_132_814] =
                 Ecto.Migrator.run(Repo, migrations, :up,
                   to: 20_261_012_132_814,
                   prefix: schema,
                   log: false
                 )

        assert Repo.query!("SELECT id, identifier, inserted_at, updated_at FROM users").rows ==
                 legacy

        assert Repo.query!("SELECT email, confirmed_at FROM users").rows == [[nil, nil]]
        assert {:ok, first} = Accounts.register_user(%{email: "first@example.com"})
        assert {:ok, second} = Accounts.register_user(%{email: "second@example.com"})
        assert first.id != 1 and second.id != 1 and first.id != second.id
        assert first.identifier == nil and second.identifier == nil

        for table <- tables,
            do: assert(Repo.query!("SELECT * FROM #{table} ORDER BY id").rows == before[table])

        assert Repo.query!("SELECT count(*) FROM users_tokens").rows == [[0]]

        assert {:error, %Postgrex.Error{}} =
                 Repo.query("UPDATE users SET email = 'FIRST@EXAMPLE.COM' WHERE id = $1", [
                   second.id
                 ])
      after
        Repo.put_dynamic_repo(original_repo)
        Repo.query!("DROP SCHEMA #{schema} CASCADE")

        for {_version, module} <- migrations do
          :code.purge(module)
          :code.delete(module)
        end
      end
    end)
  end

  # Reuse modules loaded by the other migration test, then clear this test's
  # modules so a later file-based migration run does not redefine them.
  defp auth_migrations do
    Application.app_dir(:planner, "priv/repo/migrations/*.exs")
    |> Path.wildcard()
    |> Enum.map(fn file ->
      [version, name] = file |> Path.basename(".exs") |> String.split("_", parts: 2)
      module = Module.concat(Planner.Repo.Migrations, Macro.camelize(name))
      unless Code.ensure_loaded?(module), do: Code.compile_file(file)
      {String.to_integer(version), module}
    end)
  end
end
