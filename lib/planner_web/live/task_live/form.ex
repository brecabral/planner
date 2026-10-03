defmodule PlannerWeb.TaskLive.Form do
  use PlannerWeb, :live_view

  alias Planner.Accounts
  alias Planner.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>
      <.form for={@form} id="task-form" phx-change="validate" phx-submit="save" class="space-y-4">
        <.input
          field={@form[:title]}
          type="text"
          label={gettext("Title")}
          class="w-full rounded-lg border border-slate-400 px-3 py-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700"
        />
        <footer class="flex flex-wrap items-center gap-4">
          <button
            id="save-task"
            type="submit"
            phx-disable-with={gettext("Saving...")}
            class="rounded-lg bg-indigo-700 px-4 py-2 font-semibold text-white hover:bg-indigo-800 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700 phx-submit-loading:opacity-50"
          >
            {gettext("Save task")}
          </button>
          <.link
            id="cancel-task"
            navigate={~p"/tasks"}
            class="rounded px-3 py-2 underline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700"
          >{gettext("Cancel")}</.link>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Accounts.get_default_user!()

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:page_title, gettext("New task"))
     |> assign(:form, to_form(Tasks.change_task(user)))}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset = Tasks.change_task(socket.assigns.user, task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case Tasks.create_task(socket.assigns.user, task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Task created successfully"))
         |> push_navigate(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
