defmodule PlannerWeb.TaskLiveTest do
  use PlannerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
  import Planner.TasksFixtures

  alias Planner.Labels
  alias Planner.Repo
  alias Planner.Tasks

  setup do
    %{user: user_fixture(%{identifier: "default"})}
  end

  test "panel separates pending collections, priorities, labels and persisted quota", %{
    conn: conn,
    user: user
  } do
    day = Date.utc_today()
    label = label_fixture(user, %{name: "Reading"})
    backlog = task_fixture(user, %{title: "Backlog task"})
    retry = task_fixture(user, %{title: "Retry task", label_ids: [label.id]})
    first = task_fixture(user, %{title: "First priority", label_ids: [label.id]})
    second = task_fixture(user, %{title: "Second priority"})
    assert {:ok, _} = Tasks.select_today(user, retry.id, Date.add(day, -1))
    assert {:ok, _} = Tasks.select_today(user, first.id, day)
    assert {:ok, _} = Tasks.select_today(user, second.id, day)
    foreign = task_fixture(user_fixture())

    for _ <- 1..2 do
      {:ok, view, _} = live(recycle(conn), "/tasks")
      assert has_element?(view, "#tasks #tasks-#{backlog.id}", backlog.title)
      assert has_element?(view, "#retry #retry-#{retry.id}", retry.title)
      assert has_element?(view, "#today #today-#{first.id} [data-priority]", "1")
      assert has_element?(view, "#today #today-#{second.id} [data-priority]", "2")
      assert has_element?(view, "#today-#{first.id} [data-label]", "Reading")
      assert has_element?(view, "#retry-#{retry.id} [data-label]", "Reading")
      assert has_element?(view, "#used-choices", "2")
      assert has_element?(view, "#available-choices", "1")
      assert has_element?(view, "#today-count", "2")
      assert has_element?(view, "#backlog-count", "1")
      assert has_element?(view, "#retry-count", "1")
      refute has_element?(view, "#tasks-#{foreign.id}")
      refute has_element?(view, "#tasks-#{first.id}")
      refute has_element?(view, "#tasks-#{retry.id}")
      refute has_element?(view, "[phx-click='select']")
    end
  end

  test "three completions leave the empty today list with exhausted quota after reload", %{
    conn: conn,
    user: user
  } do
    for _ <- 1..3 do
      task = task_fixture(user)
      assert {:ok, _} = Tasks.select_today(user, task.id)
      assert {:ok, _} = Tasks.complete_task(user, task.id)
    end

    for _ <- 1..2 do
      {:ok, view, _} = live(recycle(conn), "/tasks")
      assert has_element?(view, "#today-empty", "Nenhuma tarefa")
      assert has_element?(view, "#retry-empty", "Nenhuma tarefa")
      assert has_element?(view, "#tasks-empty", "Cadastre uma tarefa")
      assert has_element?(view, "#today-count", "0")
      assert has_element?(view, "#used-choices", "3")
      assert has_element?(view, "#available-choices", "0")
      assert has_element?(view, "#quota-exhausted", "esgotadas")
      refute has_element?(view, "[data-task-title]")
    end
  end

  test "registers multiple existing and new labels together", %{conn: conn, user: user} do
    first = label_fixture(user, %{name: "Reading"})
    second = label_fixture(user, %{name: "Writing"})
    foreign = label_fixture(user_fixture(), %{name: "Private label"})
    {:ok, view, _} = live(conn, "/tasks/new")
    assert has_element?(view, "#task_label_ids[multiple] option[value='#{first.id}']", "Reading")
    assert has_element?(view, "#task_label_ids option[value='#{second.id}']", "Writing")
    refute has_element?(view, "#task_label_ids option[value='#{foreign.id}']")

    assert {:ok, _, _} =
             view
             |> form("#task-form",
               task: %{
                 title: "Study",
                 label_ids: [to_string(first.id), to_string(second.id)],
                 new_label_names: "  Research  \nNotes"
               }
             )
             |> render_submit()
             |> follow_redirect(conn, "/tasks")

    assert [task] = Tasks.list_tasks(user)

    assert Enum.sort(Enum.map(Repo.preload(task, :labels).labels, & &1.name)) ==
             ["Notes", "Reading", "Research", "Writing"]

    {:ok, next, _} = live(conn, "/tasks/new")

    for label <- Labels.list_labels(user),
        do: assert(has_element?(next, "#task_label_ids option[value='#{label.id}']", label.name))
  end

  test "label errors and invalid titles roll back registration and preserve input", %{
    conn: conn,
    user: user
  } do
    existing = label_fixture(user, %{name: "Existing"})
    {:ok, view, _} = live(conn, "/tasks/new")

    view
    |> form("#task-form",
      task: %{title: "", label_ids: [to_string(existing.id)], new_label_names: "New"}
    )
    |> render_submit()

    assert has_element?(view, "#task-form", "não pode ficar em branco")
    assert has_element?(view, "#task_label_ids option[value='#{existing.id}'][selected]")
    assert has_element?(view, "#task_new_label_names", "New")
    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == [existing]

    view
    |> form("#task-form",
      task: %{
        title: "Keep title",
        label_ids: [to_string(existing.id)],
        new_label_names: "Valid\n   "
      }
    )
    |> render_submit()

    assert has_element?(view, "#task-new-labels", "é inválido")
    assert has_element?(view, "#task_title[value='Keep title']")
    assert Tasks.list_tasks(user) == []
    assert Labels.list_labels(user) == [existing]
  end

  test "forged label IDs reject the whole registration without exposing other labels", %{
    conn: conn,
    user: user
  } do
    existing = label_fixture(user)
    foreign = label_fixture(user_fixture(), %{name: "Private label"})
    {:ok, view, _} = live(conn, "/tasks/new")

    for id <- [foreign.id, -1] do
      render_submit(view, "save", %{
        "task" => %{
          "title" => "Must roll back",
          "label_ids" => [to_string(id)],
          "new_label_names" => "New"
        }
      })

      assert has_element?(view, "#task-existing-labels", "é inválido")
      refute has_element?(view, "option", "Private label")
      assert Tasks.list_tasks(user) == []
      assert Labels.list_labels(user) == [existing]
    end
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
