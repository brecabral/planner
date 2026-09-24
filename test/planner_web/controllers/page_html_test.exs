defmodule PlannerWeb.PageHTMLTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "home renders framework resources, theme controls and reconnect notices" do
    html =
      render_component(&PlannerWeb.PageHTML.home/1, flash: %{})
      |> LazyHTML.from_fragment()

    assert html |> LazyHTML.query("h1") |> LazyHTML.text() =~ "Phoenix Framework"

    assert html |> LazyHTML.query("h1 small") |> LazyHTML.text() =~
             "v#{Application.spec(:phoenix, :vsn)}"

    for {url, label} <- [
          {"https://elixirforum.com", "Converse no Elixir Forum"},
          {"https://discord.gg/elixir", "Entre no nosso servidor do Discord"},
          {"https://elixir-slack.community/", "Junte-se a nós no Slack"},
          {"https://fly.io/docs/elixir/getting-started/", "Publique sua aplicação"},
          {"https://phoenix.hexdocs.pm/overview.html", "Guias e documentação"},
          {"https://github.com/phoenixframework/phoenix", "Código-fonte"},
          {"https://github.com/phoenixframework/phoenix/blob/v#{Application.spec(:phoenix, :vsn)}/CHANGELOG.md",
           "Histórico de alterações"}
        ] do
      assert html |> LazyHTML.query("a[href='#{url}']") |> LazyHTML.text() =~ label
    end

    for {theme, label} <- [
          {"system", "Tema do sistema"},
          {"light", "Tema claro"},
          {"dark", "Tema escuro"}
        ] do
      assert html
             |> LazyHTML.query("button[data-phx-theme='#{theme}']")
             |> LazyHTML.attribute("aria-label") == [label]

      [command] =
        html
        |> LazyHTML.query("button[data-phx-theme='#{theme}']")
        |> LazyHTML.attribute("phx-click")

      assert [["dispatch", %{"event" => "phx:set-theme"}]] = Jason.decode!(command)
    end

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
    assert html |> LazyHTML.query("button[data-phx-theme]") |> Enum.count() == 3
  end
end
