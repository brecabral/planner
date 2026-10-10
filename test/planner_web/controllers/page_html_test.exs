defmodule PlannerWeb.PageHTMLTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "home renders Planner identity, entry point and reconnect notices" do
    html =
      render_component(&PlannerWeb.PageHTML.home/1, flash: %{})
      |> LazyHTML.from_fragment()

    assert html |> LazyHTML.query("h1") |> LazyHTML.text() =~ "Espaço para o que importa."
    assert html |> LazyHTML.query("nav a[href='/']") |> LazyHTML.text() =~ "Planner"

    assert html |> LazyHTML.query("#open-planner[href='/tasks']") |> LazyHTML.text() =~
             "Abrir Planner"

    assert html |> LazyHTML.query("a[href^='https://']") |> Enum.empty?()

    for {id, message} <- [
          {"client-error", "Não foi possível conectar à internet"},
          {"server-error", "Algo deu errado!"}
        ] do
      alert = LazyHTML.query(html, "##{id}")
      assert LazyHTML.text(alert) =~ message
      assert LazyHTML.text(alert) =~ "Tentando reconectar"
      assert LazyHTML.attribute(alert, "phx-connected") != []
      assert LazyHTML.attribute(alert, "phx-disconnected") != []
    end

    assert html |> LazyHTML.query("#flash-group[aria-live=polite]") |> Enum.count() == 1
    assert html |> LazyHTML.query("#client-error[role=alert][hidden]") |> Enum.count() == 1
    assert html |> LazyHTML.query("#server-error[role=alert][hidden]") |> Enum.count() == 1
    assert html |> LazyHTML.query("button[data-phx-theme]") |> Enum.count() == 0
  end
end
