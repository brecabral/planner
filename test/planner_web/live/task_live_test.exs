defmodule PlannerWeb.TaskLiveTest do
  use PlannerWeb.ConnCase

  import Phoenix.LiveViewTest
  import Planner.AccountsFixtures
  import Planner.LabelsFixtures
  import Planner.TasksFixtures

  alias Ecto.Adapters.SQL
  alias Planner.Labels
  alias Planner.Repo
  alias Planner.Tasks

  setup do
    %{user: user_fixture(%{identifier: "default"})}
  end

  test "field errors are associated with inputs and clear after correction", %{conn: conn} do
    {:ok, view, _} = live(conn, "/tasks/new")
    refute has_element?(view, "[aria-invalid='true']")
    assert has_element?(view, "#task_new_label_names[aria-describedby='new-labels-help']")

    view |> form("#task-form", task: %{title: ""}) |> render_submit()

    assert has_element?(
             view,
             "#task_title[aria-invalid='true'][aria-describedby='task_title-errors']"
           )

    assert has_element?(view, "#task_title-errors[role='alert']", "não pode ficar em branco")

    view |> form("#task-form", task: %{title: "My book"}) |> render_change()
    refute has_element?(view, "#task_title[aria-invalid='true']")
    refute has_element?(view, "#task_title-errors")

    render_submit(view, "save", %{
      "task" => %{
        "title" => "My book",
        "label_ids" => ["-1"],
        "new_label_names" => "Original"
      }
    })

    assert has_element?(
             view,
             "#task_label_ids[aria-invalid='true'][aria-describedby='task_label_ids-errors']"
           )

    assert has_element?(view, "#task_label_ids-errors[role='alert']", "é inválido")
    assert has_element?(view, "#task_new_label_names", "Original")

    view
    |> form("#task-form", task: %{title: "My book", label_ids: [], new_label_names: "Valid\n   "})
    |> render_submit()

    assert has_element?(
             view,
             "#task_new_label_names[aria-invalid='true'][aria-describedby='new-labels-help task_new_label_names-errors']"
           )

    assert has_element?(view, "#task_new_label_names-errors[role='alert']", "é inválido")
    assert has_element?(view, "#task_title[value='My book']")
  end

  test "empty panel offers registration and translated sections and plurals", %{conn: conn} do
    {:ok, view, _} = live(conn, "/tasks")
    assert has_element?(view, "#new-task[href='/tasks/new']", "Nova tarefa")
    assert has_element?(view, "#tasks-empty", "Cadastre uma tarefa")
    assert has_element?(view, "#today-empty", "Nenhuma tarefa")
    assert has_element?(view, "#retry-empty", "Nenhuma tarefa")
    assert has_element?(view, "#history-empty", "Nenhuma tarefa concluída")
    assert has_element?(view, "#available-choices", "3 escolhas disponíveis")
    assert has_element?(view, "#history-count", "0 tarefa concluída")
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
      refute has_element?(view, "#today [data-task-title]")
    end
  end

  test "selects backlog and retry, refunds only once and preserves identity and labels", %{
    conn: conn,
    user: user
  } do
    label = label_fixture(user)
    task = task_fixture(user, %{label_ids: [label.id]})
    retry = task_fixture(user)
    Tasks.select_today(user, retry.id, Date.add(Date.utc_today(), -1))
    {:ok, view, _} = live(conn, "/tasks")

    assert has_element?(
             view,
             "#select-button-#{task.id}[phx-disable-with='Salvando...']",
             "Trazer para hoje"
           )

    assert has_element?(
             view,
             "#select-button-#{task.id}[aria-labelledby='select-button-#{task.id} task-title-#{task.id}']"
           )

    assert has_element?(view, "#task-title-#{task.id}", task.title)
    view |> form("#select-#{task.id}") |> render_submit()
    assert has_element?(view, "#today-#{task.id} [data-label]", label.name)
    refute has_element?(view, "#tasks-#{task.id}")
    assert has_element?(view, "#used-choices", "1")
    render_submit(view, "select", %{"task_id" => to_string(task.id)})
    assert has_element?(view, "#used-choices", "1")
    view |> form("#select-#{retry.id}") |> render_submit()
    assert has_element?(view, "#today-#{retry.id}")
    assert has_element?(view, "#used-choices", "2")

    assert has_element?(
             view,
             "#return-button-#{task.id}[aria-labelledby='return-button-#{task.id} task-title-#{task.id}']",
             "Devolver"
           )

    assert has_element?(
             view,
             "#complete-button-#{task.id}[aria-labelledby='complete-button-#{task.id} task-title-#{task.id}']",
             "Concluir"
           )

    assert has_element?(view, "#available-choices", "1 escolha disponível")
    view |> form("#return-#{task.id}") |> render_submit()
    render_submit(view, "return", %{"task_id" => to_string(task.id)})
    assert has_element?(view, "#tasks-#{task.id} [data-label]", label.name)
    assert has_element?(view, "#used-choices", "1")
    refute has_element?(view, "#retry-#{task.id}")
    assert has_element?(view, "#today-#{retry.id} [data-priority]", "1")
    {:ok, reload, _} = live(recycle(conn), "/tasks")
    assert has_element?(reload, "#tasks-#{task.id}")
    assert has_element?(reload, "#used-choices", "1")
  end

  test "quota rejection and stale events refresh authoritative state without accepting forged ownership",
       %{conn: conn, user: user} do
    tasks = for _ <- 1..4, do: task_fixture(user)
    foreign_user = user_fixture()
    foreign = task_fixture(foreign_user)
    {:ok, view, _} = live(conn, "/tasks")
    for task <- Enum.take(tasks, 3), do: Tasks.select_today(user, task.id)
    Tasks.complete_task(user, hd(tasks).id)
    view |> form("#select-#{List.last(tasks).id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]", "esgotadas")
    assert has_element?(view, "#used-choices", "3")
    assert has_element?(view, "#today-count", "2")
    refute has_element?(view, "#tasks-#{hd(tasks).id}")

    for id <- [to_string(foreign.id), "bad", "-1"] do
      render_submit(view, "select", %{
        "task_id" => id,
        "user_id" => foreign_user.id,
        "date" => "2099-01-01"
      })

      assert has_element?(view, "#planning-error[role=alert]", "atualizado")
      refute has_element?(view, "#today-#{foreign.id}")
    end

    render_submit(view, "return", %{"task_id" => to_string(hd(tasks).id)})
    assert has_element?(view, "#planning-error[role=alert]", "atualizado")
    assert Tasks.get_task!(foreign_user, foreign.id).kind == :backlog
    assert has_element?(view, "#used-choices", "3")
  end

  test "failed persistence keeps the task and quota unchanged and reports an accessible error", %{
    conn: conn,
    user: user
  } do
    task = task_fixture(user)
    {:ok, view, _} = live(conn, "/tasks")

    SQL.query!(
      Repo,
      "ALTER TABLE daily_plans ADD CONSTRAINT reject_ui_consumption CHECK (used_choices = 0) NOT VALID"
    )

    view |> form("#select-#{task.id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]", "Não foi possível")
    assert has_element?(view, "#tasks-#{task.id}")
    refute has_element?(view, "#today-#{task.id}")
    assert has_element?(view, "#used-choices", "0")
    assert Tasks.get_task!(user, task.id).kind == :backlog
  end

  test "return failure keeps the selected task and does not refund a choice", %{
    conn: conn,
    user: user
  } do
    task = task_fixture(user)
    Tasks.select_today(user, task.id)
    {:ok, view, _} = live(conn, "/tasks")

    assert has_element?(
             view,
             "#return-button-#{task.id}[phx-disable-with='Salvando...']",
             "Devolver ao backlog"
           )

    assert has_element?(view, "#backlog-heading[tabindex='-1']")

    SQL.query!(
      Repo,
      "ALTER TABLE daily_plans ADD CONSTRAINT reject_ui_refund CHECK (used_choices = 1) NOT VALID"
    )

    view |> form("#return-#{task.id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]", "Não foi possível")
    assert has_element?(view, "#today-#{task.id}")
    refute has_element?(view, "#tasks-#{task.id}")
    assert has_element?(view, "#used-choices", "1")
    assert Tasks.get_task!(user, task.id).kind == :today
  end

  test "moves priorities with named controls, respects boundaries and persists the order", %{
    conn: conn,
    user: user
  } do
    [first, second, third] = tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: Tasks.select_today(user, task.id)
    {:ok, view, _} = live(conn, "/tasks")
    assert has_element?(view, "#move-up-#{first.id} button[disabled]", "Subir")
    assert has_element?(view, "#move-down-#{third.id} button[disabled]", "Descer")
    view |> form("#move-up-#{third.id}") |> render_submit()
    assert_today_order(view, [first, third, second])
    view |> form("#move-down-#{first.id}") |> render_submit()
    assert_today_order(view, [third, first, second])
    assert has_element?(view, "#used-choices", "3")
    assert has_element?(view, "#move-up-#{third.id} button[disabled]")
    assert has_element?(view, "#move-down-#{second.id} button[disabled]")
    {:ok, reload, _} = live(recycle(conn), "/tasks")
    assert_today_order(reload, [third, first, second])
  end

  test "stale priority set is rejected and refreshed without changing quota", %{
    conn: conn,
    user: user
  } do
    [first, second, third] = tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: Tasks.select_today(user, task.id)
    {:ok, view, _} = live(conn, "/tasks")
    Tasks.return_to_backlog(user, first.id)
    view |> form("#move-up-#{third.id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]", "prioridades")
    assert_today_order(view, [second, third])
    assert has_element?(view, "#tasks-#{first.id}")
    assert has_element?(view, "#used-choices", "2")
    view |> form("#move-up-#{third.id}") |> render_submit()
    assert_today_order(view, [third, second])
    refute has_element?(view, "#planning-error")
    assert has_element?(view, "#used-choices", "2")
  end

  test "forged priority movements cannot change another user's tasks or move past boundaries", %{
    conn: conn,
    user: user
  } do
    task = task_fixture(user)
    Tasks.select_today(user, task.id)
    foreign_user = user_fixture()
    foreign = task_fixture(foreign_user)
    Tasks.select_today(foreign_user, foreign.id)
    {:ok, view, _} = live(conn, "/tasks")

    for params <- [
          %{
            "task_id" => to_string(foreign.id),
            "direction" => "up",
            "user_id" => foreign_user.id
          },
          %{"task_id" => to_string(task.id), "direction" => "up"},
          %{"task_id" => to_string(task.id), "direction" => "sideways"},
          %{"task_id" => "bad", "direction" => "down"},
          %{}
        ] do
      render_submit(view, "reorder", params)
      assert has_element?(view, "#planning-error[role=alert]")
      assert_today_order(view, [task])
      assert has_element?(view, "#used-choices", "1")
    end

    assert Tasks.get_task!(foreign_user, foreign.id).position == 1
  end

  defp assert_today_order(view, tasks) do
    for {task, index} <- Enum.with_index(tasks, 1) do
      assert has_element?(
               view,
               "#today > #today-#{task.id}:nth-child(#{index + 1}) [data-priority]",
               "#{index}."
             )
    end
  end

  test "completes once, preserves quota and shows the original date and labels after reload", %{
    conn: conn,
    user: user
  } do
    label = label_fixture(user, %{name: "Read original"})
    task = task_fixture(user, %{title: "Original title", label_ids: [label.id]})
    Tasks.select_today(user, task.id)
    {:ok, view, _} = live(conn, "/tasks")
    assert has_element?(view, "#history-empty", "Nenhuma tarefa concluída")

    assert has_element?(
             view,
             "#complete-button-#{task.id}[phx-disable-with='Salvando...']",
             "Concluir"
           )

    view |> form("#complete-#{task.id}") |> render_submit()
    render_submit(view, "complete", %{"task_id" => to_string(task.id), "date" => "2099-01-01"})
    refute has_element?(view, "#today-#{task.id}")
    assert has_element?(view, "#history-#{task.id} [data-task-title]", "Original title")
    assert has_element?(view, "#history-#{task.id} [data-label]", "Read original")

    assert has_element?(
             view,
             "#history-#{task.id} time[datetime='#{Date.utc_today()}']",
             Calendar.strftime(Date.utc_today(), "%d/%m/%Y")
           )

    assert has_element?(view, "#history-count", "1")
    assert has_element?(view, "#used-choices", "1")
    refute has_element?(view, "#history-#{task.id} button")
    {:ok, reload, _} = live(recycle(conn), "/tasks")
    assert has_element?(reload, "#history-#{task.id}")
    assert has_element?(reload, "#history-count", "1")
    assert has_element?(reload, "#used-choices", "1")
  end

  test "three UI completions exhaust quota and history remains owned and ordered by original date",
       %{conn: conn, user: user} do
    yesterday = Date.add(Date.utc_today(), -1)
    old = task_fixture(user)
    Tasks.select_today(user, old.id, yesterday)
    Tasks.complete_task(user, old.id, yesterday)
    tasks = for _ <- 1..3, do: task_fixture(user)
    for task <- tasks, do: Tasks.select_today(user, task.id)
    foreign_user = user_fixture()
    foreign = task_fixture(foreign_user)
    Tasks.select_today(foreign_user, foreign.id)
    Tasks.complete_task(foreign_user, foreign.id)
    {:ok, view, _} = live(conn, "/tasks")
    for task <- tasks, do: view |> form("#complete-#{task.id}") |> render_submit()
    render_submit(view, "complete", %{"task_id" => to_string(old.id)})

    for panel <- [view, elem(live(recycle(conn), "/tasks"), 1)] do
      assert has_element?(panel, "#today-count", "0")
      assert has_element?(panel, "#used-choices", "3")
      assert has_element?(panel, "#quota-exhausted", "esgotadas")
      assert has_element?(panel, "#history-count", "4")
      refute has_element?(panel, "#history-#{foreign.id}")
      assert has_element?(panel, "#history-#{old.id} time[datetime='#{yesterday}']")

      for {task, index} <- Enum.with_index(Enum.reverse(tasks) ++ [old], 2) do
        assert has_element?(panel, "#history > #history-#{task.id}:nth-child(#{index})")
      end
    end
  end

  test "stale and forged completion events refresh state without inventing a completion", %{
    conn: conn,
    user: user
  } do
    task = task_fixture(user)
    Tasks.select_today(user, task.id)
    foreign_user = user_fixture()
    foreign = task_fixture(foreign_user)
    Tasks.select_today(foreign_user, foreign.id)
    {:ok, view, _} = live(conn, "/tasks")
    Tasks.return_to_backlog(user, task.id)
    view |> form("#complete-#{task.id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]")
    assert has_element?(view, "#tasks-#{task.id}")

    for id <- [to_string(foreign.id), "bad", "-1"] do
      render_submit(view, "complete", %{"task_id" => id, "user_id" => foreign_user.id})
      assert has_element?(view, "#planning-error[role=alert]")
      assert has_element?(view, "#history-count", "0")
      assert has_element?(view, "#used-choices", "0")
    end

    assert Tasks.get_task!(foreign_user, foreign.id).completed_on == nil
  end

  test "completion write failure preserves pending task, history and consumption", %{
    conn: conn,
    user: user
  } do
    task = task_fixture(user)
    Tasks.select_today(user, task.id)
    {:ok, view, _} = live(conn, "/tasks")

    SQL.query!(
      Repo,
      "ALTER TABLE tasks ADD CONSTRAINT reject_ui_completion CHECK (completed_on IS NULL) NOT VALID"
    )

    view |> form("#complete-#{task.id}") |> render_submit()
    assert has_element?(view, "#planning-error[role=alert]", "Não foi possível")
    assert has_element?(view, "#today-#{task.id}")
    assert has_element?(view, "#history-count", "0")
    assert has_element?(view, "#used-choices", "1")
    assert Tasks.get_task!(user, task.id).completed_on == nil
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
