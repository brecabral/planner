defmodule Planner.AccountsTest do
  use Planner.DataCase, async: false

  alias Ecto.Adapters.SQL.Sandbox
  alias Planner.Accounts
  alias Planner.Accounts.User

  import Planner.AccountsFixtures

  setup do
    previous = Application.fetch_env(:planner, :auto_create_default_user)

    on_exit(fn ->
      case previous do
        {:ok, value} -> Application.put_env(:planner, :auto_create_default_user, value)
        :error -> Application.delete_env(:planner, :auto_create_default_user)
      end
    end)

    :ok
  end

  test "automatic preparation is enabled only in development configuration" do
    for {env, expected} <- [dev: true, test: false, prod: false] do
      config = Config.Reader.read!("config/config.exs", env: env, target: :host)
      assert config[:planner][:auto_create_default_user] == expected
    end
  end

  test "resolution remains strict with the setting disabled or absent" do
    for setting <- [false, nil] do
      if is_nil(setting),
        do: Application.delete_env(:planner, :auto_create_default_user),
        else: Application.put_env(:planner, :auto_create_default_user, setting)

      assert_raise Ecto.NoResultsError, fn -> Accounts.resolve_default_user!() end
      assert Repo.aggregate(User, :count) == 0
    end
  end

  test "simultaneous resolutions on separate connections converge through the unique index" do
    Application.put_env(:planner, :auto_create_default_user, true)
    supervisor = start_supervised!(Task.Supervisor)
    parent = self()

    Sandbox.unboxed_run(Repo, fn ->
      assert Repo.get_by(User, identifier: "default") == nil

      try do
        holder =
          Task.Supervisor.async_nolink(supervisor, fn ->
            Sandbox.unboxed_run(Repo, fn ->
              Repo.transact(fn ->
                user = Accounts.resolve_default_user!()
                send(parent, {:inserted, user, backend_pid()})
                receive do: (:release -> {:ok, user})
              end)
            end)
          end)

        assert_receive {:inserted, user, holder_backend}, 2_000

        contender =
          Task.Supervisor.async_nolink(supervisor, fn ->
            Sandbox.unboxed_run(Repo, fn ->
              send(parent, {:contender, backend_pid()})
              Accounts.resolve_default_user!()
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

        assert Task.await(holder) == {:ok, user}
        assert Task.await(contender) == user
        assert Accounts.resolve_default_user!() == user
        assert Repo.aggregate(User, :count) == 1
      after
        for pid <- Task.Supervisor.children(supervisor),
            do: Task.Supervisor.terminate_child(supervisor, pid)

        Repo.delete_all(from u in User, where: u.identifier == "default")
      end
    end)
  end

  defp backend_pid, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  defp wait_for_lock(waiter, holder, deadline) do
    %{rows: [[blockers]]} = Repo.query!("SELECT pg_blocking_pids($1)", [waiter])

    unless holder in blockers do
      assert System.monotonic_time(:millisecond) < deadline,
             "expected PostgreSQL unique index lock wait"

      wait_for_lock(waiter, holder, deadline)
    end
  end

  test "preparation persists the default user and preserves its identity and timestamps" do
    user = Accounts.ensure_default_user!()
    assert user.identifier == "default"
    assert user.id
    assert Accounts.get_default_user!() == user
    assert Accounts.ensure_default_user!() == user
    assert Repo.aggregate(User, :count) == 1
  end

  test "lookup requires preparation and does not silently create a user" do
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_default_user!() end
    assert Repo.aggregate(User, :count) == 0
  end

  test "seeds create a missing default user exactly once" do
    Code.eval_file("priv/repo/seeds.exs")
    default = Accounts.get_default_user!()
    Code.eval_file("priv/repo/seeds.exs")
    assert Accounts.get_default_user!() == default
    assert Repo.aggregate(User, :count) == 1
  end

  test "running seeds twice preserves the existing default user and other identities" do
    default =
      user_fixture(%{identifier: "default"})
      |> Ecto.Changeset.change(updated_at: ~U[2020-01-01 00:00:00Z])
      |> Repo.update!()

    other = user_fixture()

    for _ <- 1..2, do: Code.eval_file("priv/repo/seeds.exs")

    assert Accounts.get_default_user!() == default
    assert Repo.get!(User, other.id) == other
    assert Repo.aggregate(User, :count) == 2
  end

  test "fixtures create independent persisted users without global seeds" do
    first = user_fixture()
    second = user_fixture()
    assert first.id != second.id
    assert first.identifier != second.identifier
    assert Repo.get!(User, first.id) == first
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_default_user!() end
  end

  test "user identity requires a unique nonempty identifier" do
    assert {:error, blank} = %User{} |> User.changeset(%{}) |> Repo.insert()
    assert errors_on(blank) == %{identifier: ["can't be blank"]}

    user_fixture(%{identifier: "default"})

    assert {:error, duplicate} =
             %User{} |> User.changeset(%{identifier: "default"}) |> Repo.insert()

    assert errors_on(duplicate) == %{identifier: ["has already been taken"]}
  end
end
