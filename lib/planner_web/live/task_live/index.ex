defmodule PlannerWeb.TaskLive.Index do
  use PlannerWeb, :live_view

  alias Planner.Accounts
  alias Planner.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {gettext("Planner")}
        <:actions>
          <.link
            id="new-task"
            navigate={~p"/tasks/new"}
            class="inline-flex items-center gap-2 rounded-lg bg-indigo-700 px-4 py-2 font-semibold text-white hover:bg-indigo-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700"
          >
            <.icon name="hero-plus" /> {gettext("New task")}
          </.link>
        </:actions>
      </.header>
      <p :if={@planning_error} id="planning-error" role="alert" class="text-red-700">
        {@planning_error}
      </p>
      <section aria-labelledby="today-heading" class="rounded-xl border-2 border-indigo-500 p-4">
        <h2 id="today-heading" tabindex="-1" class="text-xl font-semibold">{gettext("Today")}</h2>
        <p id="used-choices">{gettext("Choices used: %{count} of 3", count: @used_choices)}</p>
        <p id="available-choices">
          {ngettext("%{count} choice available", "%{count} choices available", @available_choices)}
        </p>
        <p :if={@available_choices == 0} id="quota-exhausted" class="font-semibold">
          {gettext("Today's choices are exhausted.")}
        </p>
        <p id="today-count">
          {ngettext("%{count} pending task", "%{count} pending tasks", @today_count)}
        </p>
        <div id="today" phx-update="stream" class="mt-4 space-y-3">
          <p id="today-empty" class="hidden only:block">
            {gettext("No tasks for today. Choose from backlog or retry.")}
          </p>
          <div
            :for={{id, task} <- @streams.today}
            id={id}
            class="break-words rounded-lg border border-slate-300 p-4"
          >
            <span data-priority class="mr-2 font-bold">{task.position}.</span>
            <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
            <.task_labels task={task} />
            <div class="mt-3 flex flex-wrap gap-2">
              <.order_action task={task} direction="up" disabled={task.position == 1} />
              <.order_action task={task} direction="down" disabled={task.position == @today_count} />
            </div>
            <.planning_action task={task} action="return" />
            <.planning_action task={task} action="complete" />
          </div>
        </div>
      </section>
      <section aria-labelledby="backlog-heading">
        <h2 id="backlog-heading" tabindex="-1" class="mb-4 text-lg font-semibold">
          {gettext("Backlog")}
        </h2>
        <p id="backlog-count">
          {ngettext("%{count} pending task", "%{count} pending tasks", @backlog_count)}
        </p>
        <div id="tasks" phx-update="stream" class="space-y-3">
          <p id="tasks-empty" class="hidden only:block">
            {gettext("Add a task to start your backlog.")}
          </p>
          <div
            :for={{id, task} <- @streams.tasks}
            id={id}
            class="break-words rounded-lg border border-slate-300 p-4"
          >
            <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
            <.task_labels task={task} />
            <.planning_action task={task} action="select" />
          </div>
        </div>
      </section>
      <section aria-labelledby="retry-heading">
        <h2 id="retry-heading" class="mb-4 text-lg font-semibold">{gettext("Retry")}</h2>
        <p id="retry-count">
          {ngettext("%{count} pending task", "%{count} pending tasks", @retry_count)}
        </p>
        <div id="retry" phx-update="stream" class="space-y-3">
          <p id="retry-empty" class="hidden only:block">
            {gettext("No unfinished tasks from previous days.")}
          </p>
          <div
            :for={{id, task} <- @streams.retry}
            id={id}
            class="break-words rounded-lg border border-slate-300 p-4"
          >
            <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
            <.task_labels task={task} />
            <.planning_action task={task} action="select" />
          </div>
        </div>
      </section>
      <section aria-labelledby="history-heading">
        <h2 id="history-heading" tabindex="-1" class="mb-4 text-lg font-semibold">
          {gettext("History")}
        </h2>
        <p id="history-count">
          {ngettext("%{count} completed task", "%{count} completed tasks", @history_count)}
        </p>
        <div id="history" phx-update="stream" class="space-y-3">
          <p id="history-empty" class="hidden only:block">{gettext("No completed tasks yet.")}</p>
          <div
            :for={{id, task} <- @streams.history}
            id={id}
            class="break-words rounded-lg border border-slate-300 p-4"
          >
            <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
            <p>
              {gettext("Completed on")}
              <time datetime={Date.to_iso8601(task.completed_on)}>{Calendar.strftime(
                task.completed_on,
                "%d/%m/%Y"
              )}</time>
            </p>
            <.task_labels task={task} />
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Accounts.get_default_user!()
    {:ok, snapshot} = Tasks.snapshot(user)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:page_title, gettext("Planner"))
     |> assign(:planning_error, nil)
     |> assign_snapshot(snapshot)}
  end

  @impl true
  def handle_event(action, params, socket) when action in ["select", "return", "complete"] do
    result = run_action(action, socket.assigns.user, Map.get(params, "task_id"))

    finish_action(socket, result)
  end

  def handle_event("reorder", params, socket) do
    ids = move_priority(socket.assigns.today_ids, params)
    finish_action(socket, run_action("reorder", socket.assigns.user, ids))
  end

  defp move_priority(ids, %{"task_id" => id, "direction" => direction})
       when direction in ["up", "down"] do
    index = Enum.find_index(ids, &(to_string(&1) == id))
    offset = if direction == "up", do: -1, else: 1

    if index != nil and index + offset >= 0 and index + offset < length(ids) do
      target = index + offset

      ids
      |> List.replace_at(index, Enum.at(ids, target))
      |> List.replace_at(target, Enum.at(ids, index))
    end
  end

  defp move_priority(_ids, _params), do: nil

  defp finish_action(socket, result) do
    error =
      case result do
        {:ok, _task} ->
          nil

        {:error, :invalid_order} ->
          gettext(
            "Priorities have changed or this movement is unavailable. The panel has been updated."
          )

        {:error, :quota_exhausted} ->
          gettext("Today's choices are exhausted.")

        {:error, reason} when reason in [:not_found, :invalid_state] ->
          gettext("This task is no longer available for this action. The panel has been updated.")

        {:error, _reason} ->
          gettext("Could not save the change. Please try again.")
      end

    socket = assign(socket, :planning_error, error)

    {:noreply, refresh_snapshot(socket)}
  end

  defp run_action(action, user, id) do
    case action do
      "select" -> Tasks.select_today(user, id)
      "return" -> Tasks.return_to_backlog(user, id)
      "reorder" -> Tasks.reorder_today(user, id)
      "complete" -> Tasks.complete_task(user, id)
    end
  rescue
    _error in [
      Ecto.ConstraintError,
      Ecto.StaleEntryError,
      Postgrex.Error,
      DBConnection.ConnectionError
    ] ->
      {:error, :persistence}
  end

  defp refresh_snapshot(socket) do
    case Tasks.snapshot(socket.assigns.user) do
      {:ok, snapshot} ->
        assign_snapshot(socket, snapshot)

      {:error, _reason} ->
        assign(socket, :planning_error, gettext("Could not refresh the panel. Please reload."))
    end
  rescue
    _error in [
      Ecto.ConstraintError,
      Ecto.StaleEntryError,
      Postgrex.Error,
      DBConnection.ConnectionError
    ] ->
      assign(socket, :planning_error, gettext("Could not refresh the panel. Please reload."))
  end

  defp assign_snapshot(socket, snapshot) do
    history = Tasks.list_history(socket.assigns.user)

    socket
    |> assign(:history_count, length(history))
    |> stream(:history, history, reset: true)
    |> assign(:used_choices, snapshot.used_choices)
    |> assign(:available_choices, snapshot.available_choices)
    |> assign(:today_count, length(snapshot.today))
    |> assign(:today_ids, Enum.map(snapshot.today, & &1.id))
    |> assign(:backlog_count, length(snapshot.backlog))
    |> assign(:retry_count, length(snapshot.retry))
    |> stream(:tasks, snapshot.backlog, reset: true)
    |> stream(:today, snapshot.today, reset: true)
    |> stream(:retry, snapshot.retry, reset: true)
  end

  attr :task, Planner.Tasks.Task, required: true
  attr :direction, :string, required: true
  attr :disabled, :boolean, required: true

  defp order_action(assigns) do
    ~H"""
    <form
      id={"move-#{@direction}-#{@task.id}"}
      phx-submit={JS.push("reorder") |> JS.focus(to: "#today-heading")}
    >
      <input type="hidden" name="task_id" value={@task.id} />
      <input type="hidden" name="direction" value={@direction} />
      <button
        id={"move-#{@direction}-button-#{@task.id}"}
        type="submit"
        disabled={@disabled}
        phx-disable-with={gettext("Saving...")}
        aria-label={
          if @direction == "up",
            do: gettext("Move %{title} up", title: @task.title),
            else: gettext("Move %{title} down", title: @task.title)
        }
        class="rounded-lg border border-indigo-700 px-3 py-2 text-indigo-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700 disabled:opacity-50"
      >
        {if @direction == "up", do: gettext("Move up"), else: gettext("Move down")}
      </button>
    </form>
    """
  end

  attr :task, Planner.Tasks.Task, required: true
  attr :action, :string, required: true

  defp planning_action(assigns) do
    {label, focus} =
      case assigns.action do
        "select" -> {gettext("Bring to today"), "#today-heading"}
        "return" -> {gettext("Return to backlog"), "#backlog-heading"}
        "complete" -> {gettext("Complete task"), "#history-heading"}
      end

    assigns = assign(assigns, label: label, focus: focus)

    ~H"""
    <form
      id={"#{@action}-#{@task.id}"}
      phx-submit={
        JS.push(@action)
        |> JS.focus(to: @focus)
      }
      class="mt-3"
    >
      <input type="hidden" name="task_id" value={@task.id} />
      <button
        id={"#{@action}-button-#{@task.id}"}
        aria-labelledby={"#{@action}-button-#{@task.id} task-title-#{@task.id}"}
        type="submit"
        phx-disable-with={gettext("Saving...")}
        class="max-w-full whitespace-normal rounded-lg border border-indigo-700 px-3 py-2 text-indigo-700 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700 disabled:opacity-50"
      >
        {@label}
      </button>
    </form>
    """
  end

  attr :task, Planner.Tasks.Task, required: true

  defp task_labels(assigns) do
    ~H"""
    <ul :if={@task.labels != []} class="mt-2 flex flex-wrap gap-2" aria-label={gettext("Labels")}>
      <li
        :for={label <- @task.labels}
        data-label
        class="rounded border border-slate-300 px-2 py-1 text-sm"
      >
        {label.name}
      </li>
    </ul>
    """
  end
end
