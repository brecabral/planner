defmodule PlannerWeb.UserLive.Registration do
  use PlannerWeb, :live_view

  alias Planner.Accounts
  alias Planner.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <section id="join" aria-labelledby="join-title" class="mx-auto max-w-sm space-y-6">
        <div class="space-y-3">
          <h1 id="join-title" class="text-3xl font-semibold tracking-tight">
            {gettext("Create your account")}
          </h1>
          <p id="join-introduction" class="text-base-content/80">
            {gettext("Organize your tasks and choose up to three priorities each day.")}
          </p>
        </div>
        <p id="join-instructions" class="text-sm text-base-content/80">
          {gettext(
            "You will receive an email link to confirm your account and log in. No password needed."
          )}
        </p>
        <.form
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          class="space-y-4"
        >
          <.input
            field={%{@form[:email] | errors: []}}
            type="email"
            label={gettext("Email")}
            autocomplete="username"
            spellcheck="false"
            required
            aria-invalid={if @email_errors != [], do: "true"}
            aria-describedby={
              if @email_errors == [],
                do: "join-instructions",
                else: "join-instructions user_email-errors"
            }
            phx-mounted={JS.focus()}
          />
          <div
            :if={@email_errors != []}
            id="user_email-errors"
            role="alert"
            class="text-sm text-error"
          >
            <p :for={error <- @email_errors}>{translate_error(error)}</p>
          </div>
          <.button
            id="registration-submit"
            phx-disable-with={gettext("Creating account...")}
            class="btn btn-primary w-full"
          >
            {gettext("Create account")}
          </.button>
        </.form>
        <p class="text-sm">
          {gettext("Already have an account?")}
          <.link
            id="join-login"
            navigate={~p"/users/log-in"}
            class="link link-primary rounded-sm focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary"
          >
            {gettext("Log in")}
          </.link>
        </p>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: PlannerWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, %{assigns: %{live_action: :legacy}} = socket) do
    {:ok, redirect(socket, to: ~p"/join")}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_email(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        socket =
          case Accounts.deliver_login_instructions(user, &url(~p"/users/log-in/#{&1}")) do
            {:ok, _} ->
              put_flash(
                socket,
                :info,
                gettext(
                  "An email was sent to %{email}, please access it to confirm your account.",
                  email: user.email
                )
              )

            {:error, _reason} ->
              put_flash(
                socket,
                :error,
                gettext("We could not send the confirmation email. Request a new link to log in.")
              )
          end

        {:noreply, push_navigate(socket, to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_email(%User{}, user_params, validate_unique: false)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    errors = if used_input?(form[:email]), do: form[:email].errors, else: []
    assign(socket, form: form, email_errors: errors)
  end
end
