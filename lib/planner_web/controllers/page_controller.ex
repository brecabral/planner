defmodule PlannerWeb.PageController do
  use PlannerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
