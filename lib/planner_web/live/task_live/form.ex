defmodule PlannerWeb.TaskLive.Form do
  use PlannerWeb, :live_view

  alias Planner.Accounts
  alias Planner.Labels
  alias Planner.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>
      <.form for={@form} id="task-form" phx-change="validate" phx-submit="save" class="space-y-4">
        <.accessible_input
          field={@form[:title]}
          type="text"
          label={gettext("Title")}
          class="w-full rounded-lg border border-slate-400 px-3 py-2 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-700"
        />
        <div id="task-existing-labels">
          <.accessible_input
            field={@label_form[:label_ids]}
            type="select"
            multiple
            options={@label_options}
            label={gettext("Existing labels")}
            class="w-full rounded-lg border border-slate-400 px-3 py-2 focus-visible:outline-2 focus-visible:outline-indigo-700"
          />
        </div>
        <div id="task-new-labels">
          <.accessible_input
            field={@label_form[:new_label_names]}
            type="textarea"
            label={gettext("New labels")}
            description="new-labels-help"
            class="w-full rounded-lg border border-slate-400 px-3 py-2 focus-visible:outline-2 focus-visible:outline-indigo-700"
          />
          <p id="new-labels-help" class="text-sm">
            {gettext("Enter one new label per line, or leave empty.")}
          </p>
        </div>
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

  attr :field, Phoenix.HTML.FormField, required: true
  attr :description, :string, default: nil
  attr :rest, :global, include: ~w(type label class options multiple)

  defp accessible_input(assigns) do
    errors = if used_input?(assigns.field), do: assigns.field.errors, else: []
    error_id = "#{assigns.field.id}-errors"

    assigns =
      assigns
      |> assign(:errors, Enum.map(errors, &translate_error/1))
      |> assign(:error_id, error_id)
      |> assign(
        :described_by,
        [assigns.description, if(errors != [], do: error_id)]
        |> Enum.reject(&is_nil/1)
        |> Enum.join(" ")
      )

    ~H"""
    <.input
      field={%{@field | errors: []}}
      aria-invalid={if @errors != [], do: "true"}
      aria-describedby={if @described_by != "", do: @described_by}
      {@rest}
    />
    <div :if={@errors != []} id={@error_id} role="alert" class="text-sm text-red-700">
      <p :for={error <- @errors}>{error}</p>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = Accounts.resolve_default_user!()

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:page_title, gettext("New task"))
     |> assign(:label_options, Enum.map(Labels.list_labels(user), &{&1.name, &1.id}))
     |> assign_forms(Tasks.change_task(user), %{})}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset = Tasks.change_task(socket.assigns.user, task_params)
    {:noreply, assign_forms(socket, %{changeset | action: :validate}, task_params)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    case Tasks.create_task(socket.assigns.user, registration_params(task_params)) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Task created successfully"))
         |> push_navigate(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_forms(socket, changeset, task_params)}
    end
  end

  defp assign_forms(socket, changeset, params) do
    label_params = %{
      "label_ids" => Map.get(params, "label_ids", []),
      "new_label_names" => Map.get(params, "new_label_names", "")
    }

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:label_form, to_form(label_params, as: :task, errors: changeset.errors))
  end

  defp registration_params(params) do
    case Map.get(params, "new_label_names", "") do
      "" ->
        Map.put(params, "new_label_names", [])

      names when is_binary(names) ->
        Map.put(params, "new_label_names", String.split(names, ~r/\r?\n/))

      _ ->
        params
    end
  end
end
