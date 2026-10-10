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
            patch={~p"/tasks/new"}
            class="btn btn-primary"
          >
            <.icon name="hero-plus" /> {gettext("New task")}
          </.link>
        </:actions>
      </.header>
      <p :if={@planning_error} id="planning-error" role="alert" class="alert alert-error">
        {@planning_error}
      </p>
      <p id="planning-status" role="status" aria-live="polite" class="text-sm text-primary">
        <span :if={@planning_status} id={"planning-result-#{@status_version}"}>{@planning_status}</span>
      </p>
      <div
        id="planning-board"
        phx-hook="TaskDrag"
        class="grid items-start gap-6 lg:grid-cols-[minmax(0,1.6fr)_minmax(0,1fr)]"
      >
        <section aria-labelledby="today-heading" class="planner-section today-section min-w-0">
          <h2 id="today-heading" tabindex="-1" class="text-3xl font-semibold tracking-tight">
            {gettext("Today")}
          </h2>
          <div aria-hidden="true" class="mb-2 mt-6 flex gap-1.5">
            <span
              :for={choice <- 1..3}
              class={[
                "h-1.5 w-9 rounded-full",
                if(choice <= @used_choices, do: "bg-primary", else: "bg-base-300")
              ]}
            />
          </div>
          <p id="used-choices" class="text-sm font-medium">
            {gettext("Choices used: %{count} of 3", count: @used_choices)}
          </p>
          <p id="available-choices">
            {ngettext("%{count} choice available", "%{count} choices available", @available_choices)}
          </p>
          <p :if={@available_choices == 0} id="quota-exhausted" class="font-semibold">
            {gettext("Today's choices are exhausted.")}
          </p>
          <p id="today-count">
            {ngettext("%{count} pending task", "%{count} pending tasks", @today_count)}
          </p>
          <div
            id="today"
            data-task-list="today"
            phx-update="stream"
            class="task-drop-zone mt-4 space-y-3"
          >
            <p id="today-empty" class="hidden only:block">
              {gettext("No tasks for today. Choose from backlog or retry.")}
            </p>
            <div
              :for={{id, task} <- @streams.today}
              id={id}
              data-task-id={task.id}
              class="task-card"
            >
              <.drag_handle task={task} />
              <span
                data-priority
                class="mr-2 inline-grid size-8 place-items-center rounded-lg bg-primary/10 font-semibold text-primary"
              >{task.position}.</span>
              <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
              <.task_labels task={task} />
              <div class="mt-3 flex flex-wrap gap-2">
                <.planning_action task={task} action="complete" />
                <.task_menu task={task} count={@today_count} />
              </div>
            </div>
          </div>
        </section>
        <div class="min-w-0 space-y-6">
          <section aria-labelledby="backlog-heading" class="planner-section">
            <h2 id="backlog-heading" tabindex="-1" class="mb-4 text-lg font-semibold">
              {gettext("Backlog")}
            </h2>
            <p id="backlog-count">
              {ngettext("%{count} pending task", "%{count} pending tasks", @backlog_count)}
            </p>
            <div
              id="tasks"
              data-task-list="backlog"
              phx-update="stream"
              class="task-drop-zone mt-4 space-y-3"
            >
              <p id="tasks-empty" class="hidden only:block">
                {gettext("Add a task to start your backlog.")}
              </p>
              <div
                :for={{id, task} <- @streams.tasks}
                id={id}
                data-task-id={task.id}
                class="task-card"
              >
                <.drag_handle task={task} />
                <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
                <.task_labels task={task} />
                <.task_menu task={task} count={@backlog_count} />
              </div>
            </div>
          </section>
          <section aria-labelledby="retry-heading" class="planner-section">
            <h2 id="retry-heading" class="mb-4 text-lg font-semibold">{gettext("Retry")}</h2>
            <p id="retry-count">
              {ngettext("%{count} pending task", "%{count} pending tasks", @retry_count)}
            </p>
            <div
              id="retry"
              data-task-list="retry"
              phx-update="stream"
              class="task-drop-zone mt-4 space-y-3"
            >
              <p id="retry-empty" class="hidden only:block">
                {gettext("No unfinished tasks from previous days.")}
              </p>
              <div
                :for={{id, task} <- @streams.retry}
                id={id}
                data-task-id={task.id}
                class="task-card"
              >
                <.drag_handle task={task} />
                <span id={"task-title-#{task.id}"} data-task-title>{task.title}</span>
                <.task_labels task={task} />
                <.task_menu task={task} count={@retry_count} />
              </div>
            </div>
          </section>
        </div>
      </div>
      <section aria-labelledby="history-heading" class="planner-section">
        <button
          id="history-toggle"
          type="button"
          phx-click="toggle_history"
          aria-expanded={to_string(@history_open)}
          aria-controls="history-content"
          class="flex min-h-11 w-full items-center justify-between gap-4 text-left"
        >
          <span id="history-heading" class="text-lg font-semibold">{gettext("History")}</span>
          <.icon
            name={if @history_open, do: "hero-chevron-up", else: "hero-chevron-down"}
            class="size-5"
          />
        </button>
        <p id="history-count">
          {ngettext("%{count} completed task", "%{count} completed tasks", @history_count)}
        </p>
        <div id="history-content" hidden={!@history_open} class="mt-4">
          <div id="history" phx-update="stream" class="mt-4 space-y-3">
            <p id="history-empty" class="hidden only:block">{gettext("No completed tasks yet.")}</p>
            <div
              :for={{id, task} <- @streams.history}
              id={id}
              class="task-card"
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
        </div>
      </section>
      <.live_component
        :if={@live_action == :new}
        module={PlannerWeb.TaskLive.Form}
        id="new-task-form"
        user={@user}
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Accounts.resolve_default_user!()
    {:ok, snapshot} = Tasks.snapshot(user)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:page_title, gettext("Planner"))
     |> assign(:planning_error, nil)
     |> assign(:planning_status, nil)
     |> assign(:status_version, 0)
     |> assign(:history_open, false)
     |> assign_snapshot(snapshot)}
  end

  @impl true
  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  @impl true
  def handle_info({PlannerWeb.TaskLive.Form, :saved}, socket) do
    {:noreply,
     socket
     |> refresh_snapshot()
     |> put_flash(:info, gettext("Task created successfully"))
     |> push_patch(to: ~p"/tasks")}
  end

  @impl true
  def handle_event("toggle_history", _params, socket) do
    {:noreply, assign(socket, :history_open, !socket.assigns.history_open)}
  end

  def handle_event(action, params, socket) when action in ["select", "return", "complete"] do
    result = run_action(action, socket.assigns.user, Map.get(params, "task_id"))

    finish_action(socket, result, action)
  end

  def handle_event("reorder", params, socket) do
    kind = Map.get(params, "kind", "today")
    ids = move_priority(Map.get(socket.assigns.list_ids, kind, []), params)
    finish_action(socket, run_action("reorder", socket.assigns.user, {kind, ids}), "reorder")
  end

  def handle_event("move_task", params, socket) do
    result = run_action("move_task", socket.assigns.user, params)
    {:noreply, socket} = finish_action(socket, result, "move_task")
    {:reply, %{ok: match?({:ok, _}, result)}, socket}
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

  defp finish_action(socket, result, action) do
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

    message = if is_nil(error), do: success_message(action)

    socket =
      assign(socket,
        planning_error: error,
        planning_status: message,
        status_version: socket.assigns.status_version + 1
      )

    {:noreply, refresh_snapshot(socket)}
  end

  defp success_message("move_task"), do: gettext("Movement saved.")
  defp success_message("complete"), do: gettext("Task completed.")
  defp success_message("return"), do: gettext("Task returned to backlog.")
  defp success_message("select"), do: gettext("Task added to today.")
  defp success_message("reorder"), do: gettext("Priorities updated.")

  defp run_action(action, user, id) do
    case action do
      "select" ->
        Tasks.select_today(user, id)

      "return" ->
        Tasks.return_to_backlog(user, id)

      "reorder" ->
        {kind, ids} = id
        Tasks.reorder_list(user, kind, ids)

      "move_task" ->
        Tasks.move_task(user, id)

      "complete" ->
        Tasks.complete_task(user, id)
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
    |> assign(
      :list_ids,
      Map.new([:today, :backlog, :retry], fn kind ->
        {Atom.to_string(kind), Enum.map(Map.fetch!(snapshot, kind), & &1.id)}
      end)
    )
    |> assign(:backlog_count, length(snapshot.backlog))
    |> assign(:retry_count, length(snapshot.retry))
    |> stream(:tasks, snapshot.backlog, reset: true)
    |> stream(:today, snapshot.today, reset: true)
    |> stream(:retry, snapshot.retry, reset: true)
  end

  attr :task, Planner.Tasks.Task, required: true

  defp drag_handle(assigns) do
    ~H"""
    <button
      type="button"
      data-drag-handle
      class="task-drag-handle btn btn-ghost btn-square"
      aria-label={gettext("Drag %{title}", title: @task.title)}
    >
      <.icon name="hero-bars-3" class="size-4" />
    </button>
    """
  end

  attr :task, Planner.Tasks.Task, required: true
  attr :count, :integer, required: true

  defp task_menu(assigns) do
    ~H"""
    <details id={"task-menu-#{@task.id}"} class="dropdown dropdown-end">
      <summary class="btn btn-ghost" aria-label={gettext("Actions for %{title}", title: @task.title)}>
        <.icon name="hero-ellipsis-horizontal" class="size-5" />
      </summary>
      <div class="dropdown-content z-10 rounded-box bg-base-100 p-2 shadow-lg">
        <.planning_action task={@task} action={if @task.kind == :today, do: "return", else: "select"} />
        <div class="flex">
          <.order_action task={@task} direction="up" disabled={@task.position == 1} />
          <.order_action task={@task} direction="down" disabled={@task.position == @count} />
        </div>
      </div>
    </details>
    """
  end

  attr :task, Planner.Tasks.Task, required: true
  attr :direction, :string, required: true
  attr :disabled, :boolean, required: true

  defp order_action(assigns) do
    ~H"""
    <form
      id={"move-#{@direction}-#{@task.id}"}
      phx-submit={JS.push("reorder", page_loading: true) |> JS.focus(to: "##{@task.kind}-heading")}
    >
      <input type="hidden" name="task_id" value={@task.id} />
      <input type="hidden" name="direction" value={@direction} />
      <input type="hidden" name="kind" value={@task.kind} />
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
        class="btn btn-ghost btn-square"
      >
        <.icon
          name={if @direction == "up", do: "hero-arrow-up", else: "hero-arrow-down"}
          class="size-4"
        />
        <span class="sr-only">{if @direction == "up",
          do: gettext("Move up"),
          else: gettext("Move down")}</span>
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
        "complete" -> {gettext("Complete task"), "#today-heading"}
      end

    assigns = assign(assigns, label: label, focus: focus)

    ~H"""
    <form
      id={"#{@action}-#{@task.id}"}
      phx-submit={
        JS.push(@action, page_loading: true)
        |> JS.focus(to: @focus)
      }
      class="inline-flex"
    >
      <input type="hidden" name="task_id" value={@task.id} />
      <button
        id={"#{@action}-button-#{@task.id}"}
        aria-labelledby={"#{@action}-button-#{@task.id} task-title-#{@task.id}"}
        type="submit"
        phx-disable-with={gettext("Saving...")}
        class={[
          "btn max-w-full whitespace-normal",
          if(@action == "complete", do: "btn-primary", else: "btn-ghost")
        ]}
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
        class="badge badge-soft text-xs"
      >
        {label.name}
      </li>
    </ul>
    """
  end
end
