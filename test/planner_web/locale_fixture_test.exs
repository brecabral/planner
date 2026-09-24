defmodule PlannerWeb.LocaleFixtureLive do
  use PlannerWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <p id="locale">{Gettext.get_locale(PlannerWeb.Gettext)}</p>
      <.input id="title" name="title" value="Keep my English title" />
    </Layouts.app>
    """
  end
end
