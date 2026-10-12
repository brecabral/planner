defmodule Planner.Accounts.UserNotifier do
  @moduledoc "Delivers translated magic link messages."
  use Gettext, backend: PlannerWeb.Gettext
  import Swoosh.Email

  alias Planner.Accounts.User
  alias Planner.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Planner", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email), do: {:ok, email}
  end

  @doc "Delivers the generated magic link flow for confirmation or login."
  def deliver_login_instructions(%User{confirmed_at: nil} = user, url) do
    deliver(
      user.email,
      gettext("Confirmation instructions"),
      gettext(
        "Hi %{email},\n\nYou can confirm your account by visiting the URL below:\n\n%{url}\n\nIf you did not create an account with us, please ignore this.",
        email: user.email,
        url: url
      )
    )
  end

  def deliver_login_instructions(user, url) do
    deliver(
      user.email,
      gettext("Log in instructions"),
      gettext(
        "Hi %{email},\n\nYou can log into your account by visiting the URL below:\n\n%{url}\n\nIf you did not request this email, please ignore this.",
        email: user.email,
        url: url
      )
    )
  end
end
