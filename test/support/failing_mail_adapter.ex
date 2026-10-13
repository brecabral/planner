defmodule Planner.FailingMailAdapter do
  @moduledoc false
  use Swoosh.Adapter

  @impl true
  def deliver(_email, _config), do: {:error, :delivery_unavailable}
end
