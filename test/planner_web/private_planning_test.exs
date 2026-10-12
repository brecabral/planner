defmodule PlannerWeb.PrivatePlanningTest do
  use PlannerWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Planner.TasksFixtures
  import Planner.LabelsFixtures
  alias Planner.Accounts
  alias Planner.Labels
  alias Planner.Repo
  alias Planner.Tasks

  test "visitors are redirected from home and all planning entries without creating identities",
       %{conn: conn} do
    for path <- ["/", "/tasks", "/tasks/new?user_id=1&auto_create_default_user=true"] do
      response = get(conn, path)
      assert redirected_to(response) == "/users/log-in"
    end

    assert Repo.aggregate(Accounts.User, :count) == 0
  end

  test "authenticated home and login redirect to dashboard", %{conn: conn} do
    conn = log_in_user(conn, authenticated_user_fixture())
    assert conn |> get("/") |> redirected_to() == "/tasks"
    assert {:error, {:redirect, %{to: "/tasks"}}} = live(conn, "/users/log-in")
  end

  test "revoked session cannot mount or reconnect planning", %{conn: conn} do
    user = authenticated_user_fixture()
    conn = log_in_user(conn, user)
    token = get_session(conn, :user_token)
    disconnected = get(conn, "/tasks/new")
    Accounts.delete_user_session_token(token)
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(disconnected)
    assert conn |> get("/tasks") |> redirected_to() == "/users/log-in"
    assert conn |> get("/tasks/new") |> redirected_to() == "/users/log-in"
  end

  test "real accounts never assume legacy ownership and direct form ignores forged owner", %{
    conn: conn
  } do
    legacy = Accounts.ensure_default_user!()
    legacy_label = label_fixture(legacy)
    legacy_task = task_fixture(legacy, %{label_ids: [legacy_label.id]})
    user = authenticated_user_fixture()
    conn = log_in_user(conn, user)
    {:ok, view, _} = live(conn, "/tasks/new?user_id=#{legacy.id}")
    assert has_element?(view, "#log-out[data-method=delete]")
    refute has_element?(view, "#tasks-#{legacy_task.id}")
    refute has_element?(view, "#task-label-#{legacy_label.id}")

    view
    |> form("#task-form", task: %{title: "My task"})
    |> render_submit(%{"task" => %{"user_id" => legacy.id}})

    assert [%{user_id: owner}] = Tasks.list_tasks(user)
    assert owner == user.id
    assert Tasks.list_tasks(legacy) == [legacy_task]
    assert Labels.list_labels(legacy) == [legacy_label]
    assert Repo.reload!(legacy) == legacy
  end

  test "A and B keep reads, labels, history and every planning command private", %{conn: conn} do
    a = authenticated_user_fixture()
    b = authenticated_user_fixture()
    own = planning_fixture(a)
    foreign = planning_fixture(b)
    {:ok, before_a} = Tasks.snapshot(a)
    {:ok, before_b} = Tasks.snapshot(b)
    {:ok, view, _} = live(log_in_user(conn, a), "/tasks/new?user_id=#{b.id}")

    for {kind, stream} <- [backlog: "tasks", retry: "retry", today: "today", completed: "history"] do
      assert has_element?(view, "##{stream}-#{Map.fetch!(own, kind).id}")
      refute has_element?(view, "##{stream}-#{Map.fetch!(foreign, kind).id}")
    end

    assert has_element?(view, "#task-label-#{own.label.id}")
    refute has_element?(view, "#task-label-#{foreign.label.id}")
    assert Tasks.list_history(a) |> Enum.map(& &1.id) == [own.completed.id]
    assert Tasks.list_history(b) |> Enum.map(& &1.id) == [foreign.completed.id]

    for {action, task} <- [
          {"select", foreign.backlog},
          {"return", foreign.today},
          {"return", foreign.retry},
          {"complete", foreign.today},
          {"request_delete", foreign.backlog}
        ] do
      render_click(view, action, %{"task_id" => task.id, "user_id" => b.id})
      refute has_element?(view, "#delete-confirmation")
      assert {:ok, ^before_a} = Tasks.snapshot(a)
      assert {:ok, ^before_b} = Tasks.snapshot(b)
    end

    render_submit(view, "delete", %{"task_id" => foreign.backlog.id})

    for kind <- ["backlog", "retry", "today"] do
      task = Map.fetch!(foreign, String.to_existing_atom(kind))
      render_click(view, "reorder", %{"kind" => kind, "task_id" => task.id, "direction" => "up"})

      render_hook(view, "move_task", %{
        "task_id" => task.id,
        "from" => kind,
        "to" => "backlog",
        "orders" => %{kind => [], "backlog" => [task.id]},
        "user_id" => b.id
      })

      assert {:ok, ^before_a} = Tasks.snapshot(a)
      assert {:ok, ^before_b} = Tasks.snapshot(b)
    end

    view
    |> form("#task-form", task: %{title: "Forged label", new_label_names: "Do not persist"})
    |> render_submit(%{"task" => %{"label_ids" => [foreign.label.id], "user_id" => b.id}})

    assert has_element?(view, "#task_label_ids-errors")
    assert Labels.list_labels(a) == [own.label]
    assert Labels.list_labels(b) == [foreign.label]
    assert {:ok, ^before_a} = Tasks.snapshot(a)
    assert {:ok, ^before_b} = Tasks.snapshot(b)
  end

  test "A exhausting its quota leaves B's quota available", %{conn: conn} do
    a = authenticated_user_fixture()
    b = authenticated_user_fixture()

    for _ <- 1..3 do
      task = task_fixture(a)
      assert {:ok, _} = Tasks.select_today(a, task.id)
    end

    task = task_fixture(b)
    {:ok, view, _} = live(log_in_user(conn, b), "/tasks")
    render_click(view, "select", %{"task_id" => task.id, "user_id" => a.id})
    assert {:ok, %{used_choices: 1}} = Tasks.snapshot(b)
    assert {:ok, %{used_choices: 3}} = Tasks.snapshot(a)
  end

  test "logout broadcasts disconnection and revokes dashboard reconnection", %{conn: conn} do
    user = authenticated_user_fixture()
    {token, _} = generate_user_magic_link_token(user)
    logged_in = post(conn, "/users/log-in", user: %{token: token})
    topic = get_session(logged_in, :live_socket_id)
    PlannerWeb.Endpoint.subscribe(topic)
    disconnected = logged_in |> recycle() |> get("/tasks")
    {:ok, _view, _} = live(disconnected)
    response = disconnected |> recycle() |> delete("/users/log-out")
    assert redirected_to(response) == "/users/log-in"
    assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^topic}
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(disconnected)
  end

  defp planning_fixture(user) do
    label = label_fixture(user)
    retry = task_fixture(user, %{label_ids: [label.id]})
    {:ok, _} = Tasks.select_today(user, retry.id, Date.add(Date.utc_today(), -1))
    today = task_fixture(user)
    {:ok, _} = Tasks.select_today(user, today.id)
    completed = task_fixture(user)
    {:ok, _} = Tasks.select_today(user, completed.id)
    {:ok, _} = Tasks.complete_task(user, completed.id)
    backlog = task_fixture(user)
    %{label: label, retry: retry, today: today, completed: completed, backlog: backlog}
  end
end
