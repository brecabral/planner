defmodule Planner.AccountsAuthConcurrencyTest do
  use Planner.DataCase, async: false
  import Planner.AccountsFixtures
  alias Ecto.Adapters.SQL.Sandbox
  alias Planner.Accounts

  test "concurrent confirmation and login consume each link only once across connections" do
    supervisor = start_supervised!(Task.Supervisor)
    parent = self()

    Sandbox.unboxed_run(Repo, fn ->
      user = unconfirmed_user_fixture()

      try do
        for _ <- 1..2 do
          {token, _} = generate_user_magic_link_token(Repo.reload!(user))

          holder =
            Task.Supervisor.async_nolink(supervisor, fn ->
              Sandbox.unboxed_run(Repo, fn ->
                Repo.transact(fn ->
                  Repo.query!("SELECT id FROM users WHERE id = $1 FOR UPDATE", [user.id])
                  send(parent, {:locked, backend_pid()})
                  receive do: (:release -> Accounts.login_user_by_magic_link(token))
                end)
              end)
            end)

          assert_receive {:locked, holder_backend}, 2_000

          contender =
            Task.Supervisor.async_nolink(supervisor, fn ->
              Sandbox.unboxed_run(Repo, fn ->
                send(parent, {:contender, backend_pid()})
                Accounts.login_user_by_magic_link(token)
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

          assert {:ok, {%Accounts.User{confirmed_at: confirmed_at}, _}} = Task.await(holder)
          assert confirmed_at
          assert {:error, :not_found} = Task.await(contender)
        end
      after
        for pid <- Task.Supervisor.children(supervisor),
            do: Task.Supervisor.terminate_child(supervisor, pid)

        Repo.delete!(Repo.reload!(user))
      end
    end)
  end

  defp backend_pid, do: Repo.query!("SELECT pg_backend_pid()").rows |> hd() |> hd()

  defp wait_for_lock(waiter, holder, deadline) do
    %{rows: [[blockers]]} = Repo.query!("SELECT pg_blocking_pids($1)", [waiter])

    unless holder in blockers do
      assert System.monotonic_time(:millisecond) < deadline, "expected PostgreSQL row lock wait"
      wait_for_lock(waiter, holder, deadline)
    end
  end
end
