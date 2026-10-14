defmodule PlannerWeb.PageControllerTest do
  use PlannerWeb.ConnCase

  test "public login stays in Brazilian Portuguese regardless of browser language", %{
    conn: conn
  } do
    for _ <- 1..2 do
      html =
        conn
        |> recycle()
        |> put_req_header("accept-language", "en-US")
        |> get(~p"/users/log-in")
        |> html_response(200)
        |> LazyHTML.from_document()

      assert html |> LazyHTML.query("html") |> LazyHTML.attribute("lang") == ["pt-BR"]
      assert LazyHTML.text(html) =~ "Planner"
      refute LazyHTML.text(html) =~ "Phoenix"
      assert LazyHTML.text(html) =~ "Entrar"

      assert html |> LazyHTML.query("#register-link") |> LazyHTML.attribute("href") == [
               "/join"
             ]

      assert html |> LazyHTML.query("html") |> LazyHTML.attribute("data-theme") == ["planner"]
      assert html |> LazyHTML.query("select") |> Enum.empty?()
    end
  end
end
