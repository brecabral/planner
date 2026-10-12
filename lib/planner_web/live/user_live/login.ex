defmodule PlannerWeb.UserLive.Login do
  use PlannerWeb, :live_view

  alias Planner.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <.header>{gettext("Log in")}</.header>
        <.link id="register-link" navigate={~p"/users/register"}>{gettext("Create an account")}</.link>
        <.form for={@form} id="login_form_magic" phx-submit="submit_magic">
          <.input
            field={@form[:email]}
            type="email"
            label={gettext("Email")}
            autocomplete="username"
            spellcheck="false"
            required
            phx-mounted={JS.focus()}
          />
          <.button class="btn btn-primary w-full">{gettext("Log in with email")}</.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: ~p"/tasks")}
  end

  def mount(_params, _session, socket) do
    email = get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])
    {:ok, assign(socket, form: to_form(%{"email" => email}, as: "user"))}
  end

  @impl true
  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(user, &url(~p"/users/log-in/#{&1}"))
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext(
         "If your email is in our system, you will receive instructions for logging in shortly."
       )
     )
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
