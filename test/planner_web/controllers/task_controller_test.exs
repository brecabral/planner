defmodule PlannerWeb.TaskRoutesTest do
  use PlannerWeb.ConnCase

  test "experimental task routes are unavailable" do
    for {method, path} <- [
          {"GET", "/tasks"},
          {"GET", "/tasks/new"},
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
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
