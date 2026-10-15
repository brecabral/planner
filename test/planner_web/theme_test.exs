defmodule PlannerWeb.ThemeTest do
  use PlannerWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  alias Planner.Accounts.Scope
  alias Planner.{Repo, Themes}

  setup :register_and_log_in_user

  test "selection survives patches, reconnect and another device without affecting B", %{
    conn: conn,
    user: user
  } do
    {:ok, view, _} = live(conn, ~p"/tasks")
    assert has_element?(view, "nav #account-theme + #log-out")
    assert has_element?(view, "nav label[for=theme-selector]", "Tema")
    assert has_element?(view, "#theme-selector option[value=planner][selected]", "Claro")
    assert has_element?(view, "#theme-selector option[value=planner_dark]", "Escuro")

    assert render(view)
           |> LazyHTML.from_fragment()
           |> LazyHTML.query("select[name=theme_code]")
           |> Enum.count() == 1

    refute has_element?(view, "main #theme-selector")
    assert has_element?(view, "#account-theme[data-theme=planner]")
    render_hook(view, "select_theme", %{"theme_code" => "planner_dark"})
    assert Repo.reload!(user).theme_code == "planner_dark"
    assert has_element?(view, "#account-theme[data-theme=planner_dark]")
    view |> element("#new-task") |> render_click()
    assert has_element?(view, "#account-theme[data-theme=planner_dark]")
    {:ok, reconnected, _} = live(conn, ~p"/tasks")
    assert has_element?(reconnected, "#account-theme[data-theme=planner_dark]")
    device = build_conn() |> log_in_user(user) |> get(~p"/tasks")

    assert html_response(device, 200)
           |> LazyHTML.from_document()
           |> LazyHTML.filter("html[data-theme=planner_dark]")
           |> Enum.any?()

    {:ok, direct, _} = live(conn, ~p"/tasks/new")
    assert has_element?(direct, "#theme-selector option[value=planner_dark][selected]")
    assert has_element?(direct, "#task-form")
    render_hook(direct, "select_theme", %{"theme_code" => "planner"})
    assert Repo.reload!(user).theme_code == "planner"
    assert has_element?(direct, "#theme-selector option[value=planner][selected]")

    other = authenticated_user_fixture()
    {:ok, b, _} = live(log_in_user(build_conn(), other), ~p"/tasks")
    assert has_element?(b, "#account-theme[data-theme=planner]")
  end

  test "invalid and forged selections preserve the confirmed theme", %{conn: conn, user: user} do
    {:ok, _} = Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})
    {:ok, view, _} = live(conn, ~p"/tasks")

    for attrs <- [%{"theme_code" => "unknown"}, %{"theme_code" => "planner", "user_id" => "-1"}] do
      render_click(view, "select_theme", attrs)
      assert has_element?(view, "#account-theme[data-theme=planner_dark]")
      assert has_element?(view, "#theme-error")
      assert Repo.reload!(user).theme_code == "planner_dark"
    end
  end

  test "ungranted preference falls back to light and is not offered", %{conn: conn, user: user} do
    {:ok, _} = Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})

    Repo.query!(
      "DELETE FROM theme_entitlements WHERE user_id = $1 AND theme_code = 'planner_dark'",
      [user.id]
    )

    page = get(conn, ~p"/tasks")

    assert html_response(page, 200)
           |> LazyHTML.from_document()
           |> LazyHTML.filter("html[data-theme=planner]")
           |> Enum.any?()

    {:ok, view, _} = live(conn, ~p"/tasks")
    refute has_element?(view, "#theme-selector option[value=planner_dark]")
    render_click(view, "select_theme", %{"theme_code" => "planner_dark"})
    assert has_element?(view, "#theme-error")
    assert has_element?(view, "#account-theme[data-theme=planner]")
  end

  test "database rejection preserves confirmed selection and displays error", %{
    conn: conn,
    user: user
  } do
    {:ok, view, _} = live(conn, ~p"/tasks")

    Repo.query!(
      "ALTER TABLE users ADD CONSTRAINT reject_dark_theme CHECK (theme_code != 'planner_dark') NOT VALID"
    )

    render_hook(view, "select_theme", %{"theme_code" => "planner_dark"})
    Repo.query!("ALTER TABLE users DROP CONSTRAINT reject_dark_theme")
    assert has_element?(view, "#account-theme[data-theme=planner]")
    assert has_element?(view, "#theme-error", "Não foi possível salvar o tema")
    assert Repo.reload!(user).theme_code == "planner"
    assert has_element?(view, "#theme-selector option[value=planner][selected]")
    render_hook(view, "select_theme", %{"theme_code" => "planner_dark"})
    assert has_element?(view, "#theme-selector option[value=planner_dark][selected]")
    refute has_element?(view, "#theme-error")
  end

  test "public login and logout stay light", %{conn: conn, user: user} do
    {:ok, _} = Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})

    for public <- [
          get(build_conn(), ~p"/users/log-in"),
          get(build_conn(), ~p"/join"),
          conn |> delete(~p"/users/log-out") |> recycle() |> get(~p"/users/log-in")
        ] do
      refute html_response(public, 200)
             |> LazyHTML.from_document()
             |> LazyHTML.query("#theme-selector")
             |> Enum.any?()

      assert html_response(public, 200)
             |> LazyHTML.from_document()
             |> LazyHTML.filter("html[data-theme=planner]")
             |> Enum.any?()
    end
  end
end
