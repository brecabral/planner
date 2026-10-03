defmodule PlannerWeb.TaskRoutesTest do
  use PlannerWeb.ConnCase

  test "planner routes resolve to the authorized LiveViews" do
    for {path, module, action} <- [
          {"/tasks", PlannerWeb.TaskLive.Index, :index},
          {"/tasks/new", PlannerWeb.TaskLive.Form, :new}
        ] do
      assert %{phoenix_live_view: {^module, ^action, _, _}} =
               Phoenix.Router.route_info(PlannerWeb.Router, "GET", path, "localhost")
    end
  end

  test "experimental show, edit and HTTP mutation routes are unavailable" do
    for {method, path} <- [
          {"POST", "/tasks"},
          {"GET", "/tasks/1"},
          {"GET", "/tasks/1/edit"},
          {"PUT", "/tasks/1"},
          {"PATCH", "/tasks/1"},
          {"DELETE", "/tasks/1"}
        ] do
      assert Phoenix.Router.route_info(PlannerWeb.Router, method, path, "localhost") == :error
    end
  end

  test "home page remains available", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Tranquilidade do protótipo à produção"
  end
end
