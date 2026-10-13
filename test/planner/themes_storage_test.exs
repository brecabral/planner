defmodule Planner.ThemesStorageTest do
  use Planner.DataCase, async: false
  alias Ecto.Adapters.SQL.Sandbox
  alias Planner.{Accounts, Themes}
  alias Planner.Accounts.{Scope, User}

  test "backfill, concurrent preparation and failed writes preserve account invariants" do
    Sandbox.unboxed_run(Repo, fn ->
      schema = "themes_migration_#{System.unique_integer([:positive])}"
      Repo.query!("CREATE SCHEMA #{schema}")
      original = Repo.get_dynamic_repo()

      config =
        Repo.config()
        |> Keyword.merge(
          name: nil,
          pool: DBConnection.ConnectionPool,
          pool_size: 4,
          parameters: [search_path: "#{schema},public"]
        )

      isolated = start_supervised!({Repo, config}, id: make_ref())
      migrations = migrations()

      try do
        Repo.put_dynamic_repo(isolated)

        Ecto.Migrator.run(Repo, migrations, :up,
          to: 20_261_012_132_814,
          prefix: schema,
          log: false
        )

        Repo.query!(
          "INSERT INTO users (identifier, email, inserted_at, updated_at) VALUES ('default', NULL, NOW(), NOW()), (NULL, 'existing@example.com', NOW(), NOW())"
        )

        before = Repo.query!("SELECT * FROM users ORDER BY id").rows
        Ecto.Migrator.run(Repo, migrations, :up, all: true, prefix: schema, log: false)

        assert Repo.query!(
                 "SELECT id, identifier, inserted_at, updated_at, email, confirmed_at FROM users ORDER BY id"
               ).rows == before

        legacy = Repo.get_by!(User, identifier: "default")
        assert legacy.email == nil
        existing = Accounts.get_user_by_email("existing@example.com")
        assert existing.theme_code == "planner"
        assert grants(existing) == [["planner", "free"], ["planner_dark", "free"]]
        assert grants(legacy) == []
        assert {:ok, fresh} = Accounts.register_user(%{email: "fresh@example.com"})
        assert grants(fresh) == grants(existing)

        assert {:error, %Postgrex.Error{postgres: %{code: :unique_violation}}} =
                 Repo.query(
                   """
                   INSERT INTO theme_entitlements (user_id, theme_code, origin, inserted_at, updated_at)
                   VALUES ($1, 'planner', 'free', NOW(), NOW())
                   """,
                   [fresh.id]
                 )

        concurrent_preparation(existing, isolated)
        assert grants(existing) == [["planner", "free"], ["planner_dark", "free"]]

        assert {:ok, _} =
                 Themes.select_theme(Scope.for_user(existing), %{"theme_code" => "planner_dark"})

        assert {:ok, _} = Themes.prepare_user(existing)
        assert Repo.reload!(existing).theme_code == "planner_dark"
        verify_rollback(existing)
      after
        Repo.put_dynamic_repo(original)
        Repo.query!("DROP SCHEMA #{schema} CASCADE")

        for {_version, module} <- migrations do
          :code.purge(module)
          :code.delete(module)
        end
      end
    end)
  end

  defp verify_rollback(user) do
    Repo.query!("""
    CREATE FUNCTION reject_dark_grant() RETURNS trigger AS $$
    BEGIN
      IF NEW.theme_code = 'planner_dark' THEN RAISE EXCEPTION 'injected grant failure'; END IF;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql
    """)

    Repo.query!(
      "CREATE TRIGGER reject_dark_grant BEFORE INSERT ON theme_entitlements FOR EACH ROW EXECUTE FUNCTION reject_dark_grant()"
    )

    assert_raise Postgrex.Error, fn -> Accounts.register_user(%{email: "failed@example.com"}) end
    refute Accounts.get_user_by_email("failed@example.com")
    Repo.query!("DELETE FROM theme_entitlements WHERE user_id = $1", [user.id])
    assert_raise Postgrex.Error, fn -> Themes.prepare_user(user) end
    assert grants(user) == []
    assert Repo.reload!(user).theme_code == "planner_dark"
    Repo.query!("DROP TRIGGER reject_dark_grant ON theme_entitlements")
    assert {:ok, _} = Themes.prepare_user(user)

    Repo.query!(
      "CREATE TRIGGER reject_dark_selection BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION reject_dark_grant()"
    )

    assert {:ok, _} = Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner"})

    assert {:error, :persistence_failed} =
             Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})

    assert Repo.reload!(user).theme_code == "planner"
    assert grants(user) == [["planner", "free"], ["planner_dark", "free"]]
  end

  defp concurrent_preparation(user, isolated) do
    Repo.query!("DELETE FROM theme_entitlements WHERE user_id = $1", [user.id])
    supervisor = start_supervised!(Task.Supervisor)
    parent = self()

    holder =
      Task.Supervisor.async_nolink(supervisor, fn ->
        Repo.put_dynamic_repo(isolated)

        Repo.transact(fn ->
          Repo.query!("SELECT id FROM users WHERE id = $1 FOR UPDATE", [user.id])
          send(parent, {:locked, backend_pid()})
          receive do: (:release -> Themes.prepare_user(user))
        end)
      end)

    assert_receive {:locked, holder_backend}, 2_000

    contender =
      Task.Supervisor.async_nolink(supervisor, fn ->
        Repo.put_dynamic_repo(isolated)

        Repo.transact(fn ->
          send(parent, {:contender, backend_pid()})
          Themes.prepare_user(user)
        end)
      end)

    try do
      assert_receive {:contender, contender_backend}, 2_000
      assert contender_backend != holder_backend

      wait_for_lock(
        contender_backend,
        holder_backend,
        System.monotonic_time(:millisecond) + 2_000
      )
    after
      send(holder.pid, :release)
    end

    assert {:ok, _} = Task.await(holder)
    assert {:ok, _} = Task.await(contender)
  end

  defp grants(user),
    do:
      Repo.query!(
        "SELECT theme_code, origin FROM theme_entitlements WHERE user_id = $1 ORDER BY theme_code",
        [user.id]
      ).rows

  defp backend_pid, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  defp wait_for_lock(waiter, holder, deadline) do
    %{rows: [[blockers]]} = Repo.query!("SELECT pg_blocking_pids($1)", [waiter])

    unless holder in blockers do
      assert System.monotonic_time(:millisecond) < deadline, "expected PostgreSQL row lock wait"
      wait_for_lock(waiter, holder, deadline)
    end
  end

  defp migrations do
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
