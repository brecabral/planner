# Private release fixture: never compiled or shipped with production code.
{:ok, _} = Application.ensure_all_started(:planner)

accounts =
  Map.new(~w(planning deletion ordering touch dialog desktop narrow), fn scenario ->
    identities =
      Enum.map(1..2, fn _ ->
        email = "e2e-#{Ecto.UUID.generate()}@example.test"
        {:ok, user} = Planner.Accounts.register_user(%{email: email})
        {token, record} = Planner.Accounts.UserToken.build_email_token(user, "login")
        Planner.Repo.insert!(record)

        unless Planner.Accounts.get_user_by_magic_link_token(token).id == user.id do
          raise "E2E authentication contract changed"
        end

        %{email: email, token: token}
      end)

    {scenario, identities}
  end)

json = Jason.encode!(accounts)

if path = System.get_env("E2E_ACCOUNTS_OUTPUT") do
  File.write!(path, json)
else
  IO.puts("E2E_ACCOUNTS=" <> json)
end
