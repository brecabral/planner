defmodule PlannerWeb.LocalMagicLinkTest do
  use PlannerWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Swoosh.TestAssertions
  alias Planner.Accounts
  alias Planner.Accounts.UserToken
  alias Planner.Repo
  alias Planner.Tasks
  alias PlannerWeb.Endpoint
  alias Plug.Swoosh.MailboxPreview
  alias Swoosh.Adapters.Local.Storage.Memory

  setup do
    mailer_config = Application.fetch_env!(:planner, Planner.Mailer)
    endpoint_config = Application.fetch_env!(:planner, Endpoint)
    Memory.delete_all()

    on_exit(fn ->
      Memory.delete_all()
      Application.put_env(:planner, Planner.Mailer, mailer_config)
      Endpoint.config_change([{Endpoint, endpoint_config}], [])
    end)

    :ok
  end

  test "test delivery records recipient and link without external email" do
    user = unconfirmed_user_fixture()

    assert {:ok, email} =
             Accounts.deliver_login_instructions(
               user,
               &"http://localhost:4002/users/log-in/#{&1}"
             )

    assert_email_sent(email)
    assert email.to == [{"", user.email}]
    [url] = Regex.run(~r{http://localhost:4002/users/log-in/[^\s]+}, email.text_body)
    token = url |> URI.parse() |> Map.fetch!(:path) |> String.split("/") |> List.last()
    assert Accounts.get_user_by_magic_link_token(token).id == user.id
    assert Memory.all() == []
  end

  test "local mailbox captures configured links and two accounts can enter isolated dashboards",
       %{conn: conn} do
    Application.put_env(:planner, Planner.Mailer, adapter: Swoosh.Adapters.Local)

    config =
      Application.fetch_env!(:planner, Endpoint)
      |> Keyword.put(:url, host: "127.0.0.1", port: 4107, scheme: "http")

    Endpoint.config_change([{Endpoint, config}], [])

    first = register_from_mailbox(conn)
    {:ok, task} = Tasks.create_task(first.user, %{title: "Only first account"})
    response = first.conn |> recycle() |> delete("/users/log-out")
    assert redirected_to(response) == "/users/log-in"
    second = register_from_mailbox(recycle(response))
    assert first.user.id != second.user.id
    {:ok, view, _} = live(second.conn |> recycle(), "/tasks")
    refute has_element?(view, "#tasks-#{task.id}")
    assert Tasks.list_tasks(second.user) == []
    logged_out = second.conn |> recycle() |> delete("/users/log-out")
    guest = recycle(logged_out)
    {:ok, login, _} = live(guest, "/users/log-in")
    login |> form("#login_form_magic", user: %{email: first.user.email}) |> render_submit()
    assert_redirect(login, "/users/log-in")
    message = Enum.find(Memory.all(), &(&1.to == [{"", first.user.email}]))
    assert message.subject == "Instruções para entrar"
    [url] = Regex.run(~r{http://[^\s]+/users/log-in/[^\s]+}, message.text_body)
    path = URI.parse(url).path
    {:ok, confirmation, _} = live(guest, path)
    assert has_element?(confirmation, "#login_form")
    token = List.last(String.split(path, "/"))
    returned = post(guest, "/users/log-in", user: %{token: token})
    {:ok, own_view, _} = live(recycle(returned), "/tasks")
    assert has_element?(own_view, "#tasks-#{task.id}")

    mailbox = Plug.Test.conn(:get, "/json") |> MailboxPreview.call([])
    assert mailbox.status == 200
    assert mailbox.resp_body =~ first.user.email
    assert mailbox.resp_body =~ second.user.email
  end

  test "delivery failure never creates a session and login retains generic feedback", %{
    conn: conn
  } do
    user = unconfirmed_user_fixture()
    Application.put_env(:planner, Planner.Mailer, adapter: Planner.FailingMailAdapter)

    assert {:error, :delivery_unavailable} =
             Accounts.deliver_login_instructions(user, &"http://localhost/#{&1}")

    {:ok, view, _} = live(conn, "/users/log-in")
    view |> form("#login_form_magic", user: %{email: user.email}) |> render_submit()
    flash = assert_redirect(view, "/users/log-in")
    assert flash["info"] =~ "Se seu e-mail estiver cadastrado"
    assert conn |> get("/tasks") |> redirected_to() == "/users/log-in"
    refute Repo.get_by(UserToken, user_id: user.id, context: "session")
    refute Repo.reload!(user).confirmed_at
  end

  test "failed registration delivery preserves the account and grants for login recovery", %{
    conn: conn
  } do
    Application.put_env(:planner, Planner.Mailer, adapter: Planner.FailingMailAdapter)
    email = unique_user_email()
    {:ok, registration, _} = live(conn, "/join")

    result =
      registration
      |> form("#registration_form", user: %{email: String.upcase(email)})
      |> render_submit()

    {:ok, login, _} = follow_redirect(result, conn, "/users/log-in")

    assert has_element?(
             login,
             "#flash-error",
             "Não foi possível enviar o e-mail de confirmação. Solicite um novo link para entrar."
           )

    refute has_element?(login, "#flash-info")
    user = Accounts.get_user_by_email(email)
    refute user.confirmed_at
    refute Repo.get_by(UserToken, user_id: user.id, context: "session")
    assert conn |> get("/tasks") |> redirected_to() == "/users/log-in"

    grants = Repo.all_by(Planner.Themes.Entitlement, user_id: user.id) |> Enum.sort_by(& &1.id)
    assert Enum.sort(Enum.map(grants, & &1.theme_code)) == ["planner", "planner_dark"]

    Application.put_env(:planner, Planner.Mailer, adapter: Swoosh.Adapters.Test)
    login |> form("#login_form_magic", user: %{email: email}) |> render_submit()
    assert_redirect(login, "/users/log-in")
    assert_received {:email, message}
    assert message.to == [{"", email}]
    [url] = Regex.run(~r{http://[^\s]+/users/log-in/[^\s]+}, message.text_body)
    path = URI.parse(url).path
    {:ok, confirmation, _} = live(conn, path)
    assert has_element?(confirmation, "#confirmation_form")
    token = List.last(String.split(path, "/"))
    logged_in = post(conn, "/users/log-in", user: %{token: token}, _action: "confirmed")
    assert redirected_to(logged_in) == "/tasks"

    assert {authenticated, _} =
             Accounts.get_user_by_session_token(get_session(logged_in, :user_token))

    assert authenticated.id == user.id
    assert authenticated.confirmed_at
    assert Repo.all_by(Planner.Accounts.User, email: email) |> Enum.map(& &1.id) == [user.id]

    assert Repo.all_by(Planner.Themes.Entitlement, user_id: user.id) |> Enum.sort_by(& &1.id) ==
             grants

    assert {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
    assert changeset.errors[:email]
  end

  test "dev uses local delivery while test uses its test adapter and production has no dev routes" do
    dev = Config.Reader.read!("config/config.exs", env: :dev, target: :host)
    test = Config.Reader.read!("config/config.exs", env: :test, target: :host)
    prod = Config.Reader.read!("config/config.exs", env: :prod, target: :host)
    assert dev[:planner][Planner.Mailer][:adapter] == Swoosh.Adapters.Local
    assert test[:planner][Planner.Mailer][:adapter] == Swoosh.Adapters.Test
    assert dev[:planner][:dev_routes] == true
    refute prod[:planner][:dev_routes]
    assert prod[:swoosh][:local] == false

    for path <- ["/dev/mailbox", "/dev/mailbox/json", "/dev/dashboard"] do
      assert Phoenix.Router.route_info(PlannerWeb.Router, "GET", path, "localhost") == :error
    end
  end

  defp register_from_mailbox(conn) do
    email = unique_user_email()
    {:ok, view, _} = live(conn, "/join")
    view |> form("#registration_form", user: %{email: email}) |> render_submit()
    assert_redirect(view, "/users/log-in")
    message = Enum.find(Memory.all(), &(&1.to == [{"", email}]))
    assert message.subject == "Instruções de confirmação"
    [url] = Regex.run(~r{http://[^\s]+/users/log-in/[^\s]+}, message.text_body)
    uri = URI.parse(url)
    assert uri.host == "127.0.0.1"
    assert uri.port == 4107
    {:ok, confirmation, _} = live(conn, uri.path)
    assert has_element?(confirmation, "#confirmation_form")
    token = List.last(String.split(uri.path, "/"))
    logged_in = post(conn, "/users/log-in", user: %{token: token})
    assert redirected_to(logged_in) == "/tasks"
    assert get_session(logged_in, :user_token)
    %{user: Accounts.get_user_by_email(email), conn: logged_in}
  end
end
