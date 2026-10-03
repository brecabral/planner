defmodule PlannerWeb.TaskLiveTest do
  use PlannerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Planner.TasksFixtures

  alias Planner.Tasks

  setup do
    %{user: user_fixture(%{identifier: "default"})}
  end

  test "opens without login and creates a persisted backlog task", %{conn: conn, user: user} do
    {:ok, index, _} = live(conn, "/tasks")
    assert has_element?(index, "#tasks-empty", "Cadastre uma tarefa")

    assert {:ok, form_view, _} =
             index
             |> element("#new-task")
             |> render_click()
             |> follow_redirect(conn, "/tasks/new")

    assert has_element?(form_view, "#task-form label", "Título")
    assert has_element?(form_view, "#save-task[phx-disable-with='Salvando...']")

    assert {:ok, index, _} =
             form_view
             |> form("#task-form", task: %{title: "Write my book"})
             |> render_submit()
             |> follow_redirect(conn, "/tasks")

    assert has_element?(index, "#flash-info", "Tarefa cadastrada")
    assert [task] = Tasks.list_tasks(user)
    assert task.kind == :backlog
    assert task.title == "Write my book"
    assert has_element?(index, "#tasks-#{task.id}", task.title)
    {:ok, reloaded, html} = live(recycle(conn), "/tasks")
    assert has_element?(reloaded, "#tasks-#{task.id}", task.title)

    assert html
           |> LazyHTML.from_document()
           |> LazyHTML.query("html")
           |> LazyHTML.attribute("lang") == ["pt-BR"]
  end

  test "validates and rejects blank titles in Portuguese without saving", %{
    conn: conn,
    user: user
  } do
    {:ok, view, _} = live(conn, "/tasks/new")
    view |> form("#task-form", task: %{title: "   "}) |> render_change()
    assert has_element?(view, "#task-form", "não pode ficar em branco")
    view |> form("#task-form", task: %{title: ""}) |> render_submit()
    assert has_element?(view, "#task-form", "não pode ficar em branco")
    refute has_element?(view, "#flash-info")
    assert Tasks.list_tasks(user) == []

    assert {:ok, _, _} =
             view |> element("#cancel-task") |> render_click() |> follow_redirect(conn, "/tasks")
  end

  test "browser params cannot switch owner or set task state", %{conn: conn, user: user} do
    other = user_fixture()
    foreign = task_fixture(other, %{title: "Private task"})
    {:ok, view, _} = live(conn, "/tasks/new?user_id=#{other.id}&return_to=show&id=#{foreign.id}")

    assert {:ok, index, _} =
             view
             |> render_submit("save", %{
               "task" => %{
                 "title" => "Owned task",
                 "user_id" => other.id,
                 "kind" => "today",
                 "completed_on" => "2026-01-01",
                 "scheduled_for" => "2026-01-01",
                 "position" => 1
               }
             })
             |> follow_redirect(conn, "/tasks")

    assert [task] = Tasks.list_tasks(user)
    assert task.user_id == user.id
    assert task.kind == :backlog
    assert is_nil(task.completed_on)
    assert is_nil(task.scheduled_for)
    assert is_nil(task.position)
    assert Tasks.list_tasks(other) == [foreign]
    refute has_element?(index, "#tasks-#{foreign.id}")
    {:ok, index, _} = live(conn, "/tasks?user_id=#{other.id}")
    assert has_element?(index, "#tasks-#{task.id}")
    refute has_element?(index, "#tasks-#{foreign.id}")
    refute has_element?(index, "[phx-click='delete']")

    assert Phoenix.Router.route_info(PlannerWeb.Router, "GET", "/tasks/#{task.id}", "localhost") ==
             :error

    assert Phoenix.Router.route_info(
             PlannerWeb.Router,
             "GET",
             "/tasks/#{task.id}/edit",
             "localhost"
           ) == :error
  end
end
