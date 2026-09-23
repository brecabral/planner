defmodule PlannerWeb.PageHTMLTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  test "home renders framework resources, theme controls and reconnect notices" do
    html =
      render_component(&PlannerWeb.PageHTML.home/1, flash: %{})
      |> LazyHTML.from_fragment()

    assert html |> LazyHTML.query("h1") |> LazyHTML.text() =~ "Phoenix Framework"

    for {url, label} <- [
          {"https://phoenix.hexdocs.pm/overview.html", "Guides & Docs"},
          {"https://github.com/phoenixframework/phoenix", "Source Code"},
          {"https://github.com/phoenixframework/phoenix/blob/v#{Application.spec(:phoenix, :vsn)}/CHANGELOG.md",
           "Changelog"}
        ] do
      assert html |> LazyHTML.query("a[href='#{url}']") |> LazyHTML.text() =~ label
    end

    assert html |> LazyHTML.query("#flash-group[aria-live=polite]") |> Enum.count() == 1
    assert html |> LazyHTML.query("#client-error[role=alert][hidden]") |> Enum.count() == 1
    assert html |> LazyHTML.query("#server-error[role=alert][hidden]") |> Enum.count() == 1
    assert html |> LazyHTML.query("button[data-phx-theme]") |> Enum.count() == 3
  end
end
