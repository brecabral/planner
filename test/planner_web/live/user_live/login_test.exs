defmodule PlannerWeb.UserLive.LoginTest do
  use PlannerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  test "registration follows login and navigates independently of its empty form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/users/log-in")

    assert has_element?(view, "#login_form_magic input[type=email][required]")

    assert has_element?(
             view,
             "#login_form_magic + a#register-link[href='/join']",
             "Criar uma conta"
           )

    assert {:error, {:live_redirect, %{to: "/join"} = redirect}} =
             view |> element("#register-link") |> render_click()

    refute Map.has_key?(Map.get(redirect, :flash, %{}), "info")
    assert_no_email_sent()
  end
end
