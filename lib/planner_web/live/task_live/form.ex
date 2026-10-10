defmodule PlannerWeb.TaskLive.Form do
  use PlannerWeb, :live_component

  alias Planner.Labels
  alias Planner.Tasks

  @impl true
  def render(assigns) do
    ~H"""
    <dialog
      id="task-dialog"
      phx-hook="TaskDrawer"
      aria-modal="true"
      aria-labelledby="task-dialog-title"
      class="task-drawer"
    >
      <div class="p-6 sm:p-8">
        <header class="mb-8 flex items-center justify-between gap-4">
          <h2 id="task-dialog-title" class="text-2xl font-semibold">{gettext("New task")}</h2>
          <.link
            id="close-task"
            patch={~p"/tasks"}
            class="btn btn-ghost btn-square"
            aria-label={gettext("Close")}
          >
            <.icon name="hero-x-mark" class="size-5" />
          </.link>
        </header>
        <p :if={@save_error} id="flash-error" role="alert" class="alert alert-error mb-4">
          {@save_error}
        </p>
        <.form
          for={@form}
          id="task-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          class="space-y-6"
        >
          <.accessible_input
            field={@form[:title]}
            type="text"
            label={gettext("Title")}
            required
            autofocus
            class="input w-full"
          />
          <details id="task-labels" open={@label_errors} data-errors={to_string(@label_errors)}>
            <summary class="min-h-11 cursor-pointer py-3 text-sm font-medium">
              {gettext("Labels (optional)")}
            </summary>
            <div class="mt-4 space-y-5">
              <div id="task-existing-labels">
                <fieldset
                  id="task_label_ids"
                  aria-invalid={if @label_form[:label_ids].errors != [], do: "true"}
                  aria-describedby={
                    if @label_form[:label_ids].errors != [], do: "task_label_ids-errors"
                  }
                >
                  <legend class="mb-3 text-sm font-semibold">{gettext("Existing labels")}</legend>
                  <input type="hidden" name="task[label_ids][]" value="" />
                  <label
                    :for={{name, id} <- @label_options}
                    class="flex min-h-11 items-center gap-3 break-all"
                  >
                    <input
                      type="checkbox"
                      id={"task-label-#{id}"}
                      name="task[label_ids][]"
                      value={id}
                      checked={to_string(id) in @selected_labels}
                      class="checkbox checkbox-primary"
                    />
                    {name}
                  </label>
                </fieldset>
                <div
                  :if={@label_form[:label_ids].errors != []}
                  id="task_label_ids-errors"
                  role="alert"
                  class="text-sm text-error"
                >
                  <p :for={error <- @label_form[:label_ids].errors}>{translate_error(error)}</p>
                </div>
              </div>
              <div id="task-new-labels">
                <.accessible_input
                  field={@label_form[:new_label_names]}
                  type="textarea"
                  label={gettext("New labels")}
                  description="new-labels-help"
                  class="textarea min-h-28 w-full"
                />
                <p id="new-labels-help" class="mt-2 text-sm text-base-content/70">
                  {gettext("Enter one new label per line, or leave empty.")}
                </p>
              </div>
            </div>
          </details>
          <footer class="flex flex-wrap items-center gap-3 border-t border-base-300 pt-6">
            <button
              id="save-task"
              type="submit"
              phx-disable-with={gettext("Saving...")}
              class="btn btn-primary phx-submit-loading:opacity-50"
            >{gettext("Save task")}</button>
            <.link id="cancel-task" patch={~p"/tasks"} class="btn btn-ghost">{gettext("Cancel")}</.link>
          </footer>
        </.form>
      </div>
    </dialog>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :description, :string, default: nil
  attr :rest, :global, include: ~w(type label class options multiple required autofocus)

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
    <div :if={@errors != []} id={@error_id} role="alert" class="text-sm text-error">
      <p :for={error <- @errors}>{error}</p>
    </div>
    """
  end

  @impl true
  def update(assigns, %{assigns: %{form: _form}} = socket) do
    {:ok, assign(socket, assigns)}
  end

  def update(%{user: user} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:save_error, nil)
     |> assign(:label_options, Enum.map(Labels.list_labels(user), &{&1.name, &1.id}))
     |> assign_forms(Tasks.change_task(user), %{})}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    task_params = normalize_labels(task_params)
    changeset = Tasks.change_task(socket.assigns.user, task_params)
    {:noreply, assign_forms(socket, %{changeset | action: :validate}, task_params)}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    task_params = normalize_labels(task_params)
    socket = assign(socket, :save_error, nil)

    case create_task(socket.assigns.user, registration_params(task_params)) do
      {:ok, _task} ->
        send(self(), {__MODULE__, :saved})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_forms(socket, changeset, task_params)}

      {:error, :persistence} ->
        changeset = Tasks.change_task(socket.assigns.user, task_params)

        {:noreply,
         socket
         |> assign_forms(changeset, task_params)
         |> assign(:save_error, gettext("Could not create the task. Please try again."))}
    end
  end

  defp create_task(user, params) do
    Tasks.create_task(user, params)
  rescue
    _error in [Ecto.ConstraintError, Postgrex.Error, DBConnection.ConnectionError] ->
      {:error, :persistence}
  end

  defp assign_forms(socket, changeset, params) do
    label_params = %{
      "label_ids" => Map.get(params, "label_ids", []),
      "new_label_names" => Map.get(params, "new_label_names", "")
    }

    socket
    |> assign(
      :label_errors,
      Keyword.has_key?(changeset.errors, :label_ids) or
        Keyword.has_key?(changeset.errors, :new_label_names)
    )
    |> assign(:selected_labels, selected_labels(label_params["label_ids"]))
    |> assign(:form, to_form(changeset))
    |> assign(:label_form, to_form(label_params, as: :task, errors: changeset.errors))
  end

  defp selected_labels(ids) do
    for id <- List.wrap(ids), is_binary(id) or is_integer(id), do: to_string(id)
  end

  defp normalize_labels(params) do
    Map.update(params, "label_ids", [], fn
      ids when is_list(ids) -> Enum.reject(ids, &(&1 == ""))
      invalid -> invalid
    end)
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
