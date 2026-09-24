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
      assert LazyHTML.text(html) =~ "Tranquilidade do protótipo à produção."
      assert LazyHTML.text(html) =~ "Crie aplicações web ricas e interativas"
      refute LazyHTML.text(html) =~ "Peace of mind"
      refute LazyHTML.text(html) =~ "Build rich"
      assert html |> LazyHTML.query("select") |> Enum.empty?()
    end
  end
end
