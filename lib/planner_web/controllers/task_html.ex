defmodule PlannerWeb.TaskHTML do
  use PlannerWeb, :html

  embed_templates "task_html/*"

  @doc """
  Renders a task form.

  The form is defined in the template at
  task_html/task_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def task_form(assigns)
end
