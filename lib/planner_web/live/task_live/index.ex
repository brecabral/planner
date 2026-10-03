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
      <section aria-labelledby="backlog-heading">
        <h2 id="backlog-heading" class="mb-4 text-lg font-semibold">{gettext("Backlog")}</h2>
        <div id="tasks" phx-update="stream" class="space-y-3">
          <p id="tasks-empty" class="hidden only:block">
            {gettext("Add a task to start your backlog.")}
          </p>
          <div
            :for={{id, task} <- @streams.tasks}
            id={id}
            class="break-words rounded-lg border border-slate-300 p-4"
          >
            {task.title}
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
     |> stream(:tasks, snapshot.backlog)}
  end
end
