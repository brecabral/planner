defmodule PlannerWeb.AuthenticationFlowTest do
  use PlannerWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Swoosh.TestAssertions
  alias Planner.Accounts

  test "registration validates, normalizes email and sends translated confirmation", %{conn: conn} do
    {:ok, view, _} = live(conn, ~p"/users/register")
    assert has_element?(view, "#registration_form", "Criar uma conta")
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
    assert session = get_session(logged_in, :user_token)
    assert {authenticated, _} = Accounts.get_user_by_session_token(session)
    assert authenticated.id == user.id
    assert authenticated.confirmed_at
    reused = post(conn, ~p"/users/log-in", user: %{token: token})
    refute get_session(reused, :user_token)
    assert redirected_to(reused) == ~p"/users/log-in"
    logged_out = logged_in |> recycle() |> delete(~p"/users/log-out")
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
