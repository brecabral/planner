defmodule Planner.Themes.Theme do
  use Ecto.Schema

  @primary_key {:code, :string, autogenerate: false}
  schema "themes" do
  end
end
