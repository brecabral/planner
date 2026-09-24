defmodule PlannerWeb.LocaleTest do
  use PlannerWeb.ConnCase
  import Phoenix.LiveViewTest

  test "new LiveView processes use Portuguese and preserve user content", %{conn: conn} do
    for _ <- 1..2 do
      {:ok, view, html} = live_isolated(conn, PlannerWeb.LocaleFixtureLive)
      assert has_element?(view, "#locale", "pt_BR")
      assert has_element?(view, "#title[value='Keep my English title']")
      assert has_element?(view, "a[href='https://phoenixframework.org/']", "Site")

      assert has_element?(
               view,
               "a[href='https://phoenix.hexdocs.pm/overview.html']",
               "Comece aqui"
             )

      assert has_element?(view, "button[aria-label='Tema do sistema']")
      assert html =~ "Tentando reconectar"
      GenServer.stop(view.pid)
    end
  end

  test "Portuguese validation handles singular and plural counts" do
    assert PlannerWeb.CoreComponents.translate_error(
             {"should be at least %{count} character(s)", count: 1}
           ) == "deve ter pelo menos 1 caractere"

    assert PlannerWeb.CoreComponents.translate_error(
             {"should be at least %{count} character(s)", count: 2}
           ) == "deve ter pelo menos 2 caracteres"
  end
end
