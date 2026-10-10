defmodule PlannerWeb.PageControllerTest do
  use PlannerWeb.ConnCase

  test "GET / stays in Brazilian Portuguese on reload regardless of browser language", %{
    conn: conn
  } do
    for _ <- 1..2 do
      html =
        conn
        |> recycle()
        |> put_req_header("accept-language", "en-US")
        |> get(~p"/")
        |> html_response(200)
        |> LazyHTML.from_document()

      assert html |> LazyHTML.query("html") |> LazyHTML.attribute("lang") == ["pt-BR"]
      assert LazyHTML.text(html) =~ "Planner"
      refute LazyHTML.text(html) =~ "Phoenix"
      assert LazyHTML.text(html) =~ "Abrir Planner"
      assert LazyHTML.text(html) =~ "Espaço para o que importa."
      assert html |> LazyHTML.query("#open-planner") |> LazyHTML.attribute("href") == ["/tasks"]
      assert html |> LazyHTML.query("html") |> LazyHTML.attribute("data-theme") == ["planner"]
      assert html |> LazyHTML.query("select") |> Enum.empty?()
    end
  end
end
