defmodule PlannerWeb.PageController do
  use PlannerWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: if(conn.assigns.current_scope, do: ~p"/tasks", else: ~p"/users/log-in"))
  end
end
