defmodule Planner.UserTransactionTest do
  use ExUnit.Case, async: false

  import Ecto.Query
  import Planner.AccountsFixtures

  alias Ecto.Adapters.SQL.Sandbox
  alias Ecto.Changeset
  alias Planner.Accounts.User
  alias Planner.Repo
  alias Planner.Tasks.DailyPlan
  alias Planner.UserTransaction

  @day ~D[2026-09-25]

  setup do
    # Separate committed connections are necessary to exercise PostgreSQL locks.
    :ok = Sandbox.checkout(Repo, sandbox: false)
    user = user_fixture()
    other = user_fixture()

    on_exit(fn ->
      Sandbox.unboxed_run(Repo, fn ->
        ids = [user.id, other.id]
        Repo.delete_all(from plan in DailyPlan, where: plan.user_id in ^ids)
        Repo.delete_all(from user in User, where: user.id in ^ids)
      end)
    end)

    %{user: user, other: other}
  end

  test "a new day starts at zero and existing consumption is reused", %{user: user, other: other} do
    assert {:ok, plan} =
             UserTransaction.run(
               user,
               fn day, plan ->
                 assert day == @day
                 assert plan.day == day
                 assert plan.user_id == user.id
                 assert plan.used_choices == 0
                 {:ok, consume(plan)}
               end,
               @day
             )

    assert {:ok, ^plan} = UserTransaction.run(user, &return_plan/2, @day)

    assert {:ok, %{used_choices: 0}} =
             UserTransaction.run(user, &return_plan/2, Date.add(@day, 1))

    assert {:ok, %{used_choices: 0}} = UserTransaction.run(other, &return_plan/2, @day)
  end

  test "the default date is captured inside the locked transaction", %{user: user} do
    before = Date.utc_today()

    assert {:ok, day} =
             UserTransaction.run(user, fn day, plan ->
               assert Repo.in_transaction?()
               assert day == plan.day
               {:ok, day}
             end)

    assert day in [before, Date.utc_today()]
  end

  test "callback errors roll back quota creation and subsequent consumption", %{user: user} do
    assert {:error, :rejected} =
             UserTransaction.run(
               user,
               fn _day, plan ->
                 consume(plan)
                 {:error, :rejected}
               end,
               @day
             )

    assert plans(user) == []
    assert {:ok, original} = UserTransaction.run(user, &return_plan/2, @day)

    assert {:error, :rejected} =
             UserTransaction.run(
               user,
               fn _day, plan ->
                 consume(plan)
                 user |> Changeset.change(identifier: "rolled back") |> Repo.update!()
                 {:error, :rejected}
               end,
               @day
             )

    assert plans(user) == [original]
    assert Repo.get!(User, user.id).identifier == user.identifier
  end

  test "exceptions roll back writes", %{user: user} do
    assert_raise RuntimeError, "command failed", fn ->
      UserTransaction.run(
        user,
        fn _day, plan ->
          consume(plan)
          raise "command failed"
        end,
        @day
      )
    end

    assert plans(user) == []
  end

  test "concurrent transactions serialize even before the first quota exists", %{user: user} do
    parent = self()

    first =
      worker(fn ->
        UserTransaction.run(
          user,
          fn _day, plan ->
            send(parent, {:first_locked, backend_pid()})
            receive do: (:release -> :ok)
            {:ok, consume(plan)}
          end,
          @day
        )
      end)

    assert_receive {:first_locked, first_backend}, 2_000

    second =
      worker(fn ->
        send(parent, {:second_started, backend_pid()})
        UserTransaction.run(user, fn _day, plan -> {:ok, consume(plan)} end, @day)
      end)

    assert_receive {:second_started, second_backend}, 2_000
    assert first_backend != second_backend
    assert_blocked_by(second_backend, first_backend)
    send(first.pid, :release)

    assert {:ok, %{used_choices: 1}} = Task.await(first)
    assert {:ok, %{used_choices: 2}} = Task.await(second)
    assert [%{used_choices: 2}] = plans(user)
  end

  test "another user can commit while the first user's lock is held", %{user: user, other: other} do
    parent = self()

    first =
      worker(fn ->
        UserTransaction.run(
          user,
          fn _day, plan ->
            send(parent, :first_locked)
            receive do: (:release -> :ok)
            {:ok, consume(plan)}
          end,
          @day
        )
      end)

    assert_receive :first_locked, 2_000
    second = worker(fn -> UserTransaction.run(other, &return_plan/2, @day) end)
    assert {:ok, %{user_id: other_id, used_choices: 0}} = Task.await(second)
    assert other_id == other.id
    send(first.pid, :release)
    assert {:ok, %{used_choices: 1}} = Task.await(first)
  end

  test "schema validates the quota range and preserves server-owned identity", %{
    user: user,
    other: other
  } do
    plan = %DailyPlan{user_id: user.id, day: @day}

    for count <- [0, 3] do
      assert DailyPlan.changeset(plan, %{used_choices: count}).valid?
    end

    for count <- [-1, 4, nil, "invalid"] do
      refute DailyPlan.changeset(plan, %{used_choices: count}).valid?
    end

    refute DailyPlan.changeset(%DailyPlan{}).valid?

    changeset = DailyPlan.changeset(plan, %{user_id: other.id, day: Date.add(@day, 1)})
    assert Changeset.get_field(changeset, :user_id) == user.id
    assert Changeset.get_field(changeset, :day) == @day
  end

  test "the database enforces default, required fields, range, owner and day uniqueness", %{
    user: user
  } do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    row = %{user_id: user.id, day: @day, inserted_at: now, updated_at: now}
    assert {1, nil} = Repo.insert_all("daily_plans", [row])
    assert [%{used_choices: 0}] = plans(user)

    for count <- [-1, 4] do
      error =
        assert_raise Postgrex.Error, fn ->
          Repo.insert_all("daily_plans", [Map.put(row, :used_choices, count)])
        end

      assert error.postgres.code == :check_violation
    end

    for field <- [:user_id, :day, :used_choices] do
      error =
        assert_raise Postgrex.Error, fn ->
          Repo.insert_all("daily_plans", [Map.put(row, field, nil)])
        end

      assert error.postgres.code == :not_null_violation
    end

    error = assert_raise Postgrex.Error, fn -> Repo.insert_all("daily_plans", [row]) end
    assert error.postgres.code == :unique_violation

    error =
      assert_raise Postgrex.Error, fn ->
        Repo.insert_all("daily_plans", [%{row | user_id: -1}])
      end

    assert error.postgres.code == :foreign_key_violation
    assert [%{used_choices: 0}] = plans(user)
  end

  test "a missing user cannot create a quota or run a command", %{user: user} do
    Repo.delete!(user)

    assert_raise Ecto.NoResultsError, fn ->
      UserTransaction.run(user, fn _day, _plan -> flunk("unexpected command") end, @day)
    end

    assert plans(user) == []
  end

  test "committed consumption survives a repository process and connection pool restart", %{
    user: user
  } do
    name = __MODULE__.RestartRepo

    spec =
      Supervisor.child_spec({Repo, name: name, pool: DBConnection.ConnectionPool, pool_size: 1},
        id: name
      )

    first_pid = start_supervised!(spec)
    original_repo = Repo.put_dynamic_repo(name)

    try do
      assert {:ok, saved} =
               UserTransaction.run(user, fn _day, plan -> {:ok, consume(plan)} end, @day)

      first_backend = backend_pid()
      monitor = Process.monitor(first_pid)
      stop_supervised!(name)
      assert_receive {:DOWN, ^monitor, :process, ^first_pid, :shutdown}

      second_pid = start_supervised!(spec)
      assert second_pid != first_pid
      assert backend_pid() != first_backend
      assert {:ok, ^saved} = UserTransaction.run(user, &return_plan/2, @day)
      assert [%{used_choices: 1}] = plans(user)
    after
      Repo.put_dynamic_repo(original_repo)
    end
  end

  defp return_plan(_day, plan), do: {:ok, plan}

  defp consume(plan) do
    plan |> DailyPlan.changeset(%{used_choices: plan.used_choices + 1}) |> Repo.update!()
  end

  defp plans(user), do: Repo.all(from plan in DailyPlan, where: plan.user_id == ^user.id)

  defp worker(fun) do
    supervisor = start_supervised!({Task.Supervisor, name: nil}, id: make_ref())
    Task.Supervisor.async_nolink(supervisor, fn -> Sandbox.unboxed_run(Repo, fun) end)
  end

  defp backend_pid, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  defp assert_blocked_by(waiter, holder) do
    deadline = System.monotonic_time(:millisecond) + 2_000
    wait_for_lock(waiter, holder, deadline)
  end

  defp wait_for_lock(waiter, holder, deadline) do
    %{rows: [[blockers]]} = Repo.query!("SELECT pg_blocking_pids($1)", [waiter])

    if holder not in blockers do
      assert System.monotonic_time(:millisecond) < deadline,
             "expected a real PostgreSQL lock wait"

      wait_for_lock(waiter, holder, deadline)
    end
  end
end
