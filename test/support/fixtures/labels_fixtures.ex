defmodule Planner.LabelsFixtures do
  @moduledoc """
  Creates labels for an explicit test user.
  """

  alias Planner.Labels

  @doc """
  Generates a label owned by the supplied user.
  """
  def label_fixture(user, attrs \\ %{}) do
    {:ok, label} = Labels.create_label(user, Enum.into(attrs, %{name: "some name"}))
    label
  end
end
