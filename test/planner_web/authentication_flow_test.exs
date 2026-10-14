defmodule PlannerWeb.AuthenticationFlowTest do
  use PlannerWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Swoosh.TestAssertions
  alias Planner.Accounts

  test "registration validates, normalizes email and sends translated confirmation", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/join")
    assert has_element?(view, "#registration_form", "Criar conta")
    refute has_element?(view, "input[type=password]")
    view |> form("#registration_form", user: %{email: "bad"}) |> render_change()
    assert has_element?(view, "#registration_form p", "deve conter @ e não ter espaços")
    email = unique_user_email()
    view |> form("#registration_form", user: %{email: String.upcase(email)}) |> render_submit()
    assert_redirect(view, ~p"/users/log-in")
    assert user = Accounts.get_user_by_email(email)
    refute user.confirmed_at

    assert_email_sent(fn message ->
      assert message.to == [{"", email}]
      assert message.subject == "Instruções de confirmação"
      assert message.text_body =~ "Confirme sua conta"
      assert message.text_body =~ "/users/log-in/"
    end)
  end

  test "join presents an accessible single email form and login navigation", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/join")
    assert has_element?(view, "h1", "Crie sua conta")

    assert has_element?(
             view,
             "#join-introduction",
             "Organize suas tarefas e escolha até três prioridades por dia."
           )

    assert has_element?(
             view,
             "#join-instructions",
             "Você receberá um link por e-mail para confirmar sua conta e entrar. Não é necessário criar senha."
           )

    assert has_element?(view, "label[for=user_email]", "E-mail")
    assert has_element?(view, "#user_email[aria-describedby=join-instructions]")

    assert view
           |> render()
           |> LazyHTML.from_fragment()
           |> LazyHTML.query("#registration_form input:not([type=hidden])")
           |> Enum.count() == 1

    assert has_element?(
             view,
             "#registration-submit[phx-disable-with='Criando conta...']",
             "Criar conta"
           )

    assert has_element?(view, "#join-login[href='/users/log-in']", "Entrar")
    {:ok, login, _} = live(conn, ~p"/users/log-in")

    assert {:error, {:live_redirect, %{to: "/join"}}} =
             login |> element("#register-link") |> render_click()
  end

  test "legacy registration redirects and authenticated visitors cannot register", %{conn: conn} do
    assert conn |> get(~p"/users/register") |> redirected_to() == "/join"
    assert {:error, {:redirect, %{to: "/join"}}} = live(conn, ~p"/users/register")
    conn = log_in_user(conn, authenticated_user_fixture())

    for path <- [~p"/join", ~p"/users/register"] do
      assert conn |> get(path) |> redirected_to() == "/tasks"
      assert {:error, {:redirect, %{to: "/tasks"}}} = live(conn, path)
    end
  end

  test "invalid and duplicate registration preserve input and associate translated errors", %{
    conn: conn
  } do
    user = authenticated_user_fixture()
    count = Planner.Repo.aggregate(Planner.Accounts.User, :count)

    for {email, error, value} <- [
          {"bad", "deve conter @ e não ter espaços", "bad"},
          {"  " <> String.upcase(user.email) <> "  ", "já está em uso", user.email}
        ] do
      {:ok, view, _} = live(conn, ~p"/join")
      view |> form("#registration_form", user: %{email: email}) |> render_submit()

      assert has_element?(
               view,
               "#user_email[aria-invalid=true][aria-describedby='join-instructions user_email-errors']"
             )

      assert has_element?(view, "#user_email[value='#{value}']")
      assert has_element?(view, "#user_email-errors[role=alert]", error)
      assert has_element?(view, "#join-login[href='/users/log-in']")
      assert Planner.Repo.aggregate(Planner.Accounts.User, :count) == count
    end
  end

  test "login requests have identical generic feedback for existing and absent emails", %{
    conn: conn
  } do
    user = authenticated_user_fixture()

    for email <- [user.email, "absent@example.com"] do
      {:ok, view, _} = live(conn, ~p"/users/log-in")
      refute has_element?(view, "input[type=password]")
      view |> form("#login_form_magic", user: %{email: email}) |> render_submit()
      assert flash = assert_redirect(view, ~p"/users/log-in")
      assert flash["info"] =~ "Se seu e-mail estiver cadastrado"
    end
  end

  test "confirmation submits to controller, authenticates once and logout revokes session", %{
    conn: conn
  } do
    user = unconfirmed_user_fixture()
    {token, _} = generate_user_magic_link_token(user)
    {:ok, view, _} = live(conn, ~p"/users/log-in/#{token}")
    assert has_element?(view, "#confirmation_form input[name=_csrf_token]")
    view |> form("#confirmation_form", user: %{token: token}) |> render_submit()
    assert has_element?(view, "#confirmation_form[phx-trigger-action]")
    logged_in = post(conn, ~p"/users/log-in", user: %{token: token}, _action: "confirmed")
    assert redirected_to(logged_in) == ~p"/tasks"
    assert session = get_session(logged_in, :user_token)
    assert {authenticated, _} = Accounts.get_user_by_session_token(session)
    assert authenticated.id == user.id
    assert authenticated.confirmed_at
    reused = post(conn, ~p"/users/log-in", user: %{token: token})
    refute get_session(reused, :user_token)
    assert redirected_to(reused) == ~p"/users/log-in"
    logged_out = logged_in |> recycle() |> delete(~p"/users/log-out")
    assert redirected_to(logged_out) == ~p"/users/log-in"
    refute get_session(logged_out, :user_token)
    refute Accounts.get_user_by_session_token(session)
  end

  test "invalid link offers login and password parameters cannot create a session", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/users/log-in"}}} =
             live(conn, ~p"/users/log-in/invalid!")

    conn = post(conn, ~p"/users/log-in", user: %{email: "a@example.com", password: "secret"})
    refute get_session(conn, :user_token)
    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "confirmed users can request a translated login email and authenticate again", %{
    conn: conn
  } do
    user = authenticated_user_fixture()

    assert {:ok, message} =
             Accounts.deliver_login_instructions(user, &"https://example.test/#{&1}")

    assert message.subject == "Instruções para entrar"
    assert message.text_body =~ "Entre na sua conta"
    {token, _} = generate_user_magic_link_token(user)
    {:ok, view, _} = live(conn, ~p"/users/log-in/#{token}")
    assert has_element?(view, "#login_form")
    refute has_element?(view, "#confirmation_form")
    view |> form("#login_form", user: %{token: token}) |> render_submit()
    assert has_element?(view, "#login_form[phx-trigger-action]")
    conn = post(conn, ~p"/users/log-in", user: %{token: token})
    assert get_session(conn, :user_token)
  end

  test "login POST enforces CSRF protection", %{conn: conn} do
    conn = Plug.Conn.put_private(conn, :plug_skip_csrf_protection, false)

    assert_raise Plug.CSRFProtection.InvalidCSRFTokenError, fn ->
      post(conn, ~p"/users/log-in", user: %{token: "invalid"})
    end
  end
end
