defmodule Planner.Themes.Entitlement do
  use Ecto.Schema

  schema "theme_entitlements" do
    belongs_to :user, Planner.Accounts.User

    belongs_to :theme, Planner.Themes.Theme,
      foreign_key: :theme_code,
      references: :code,
      type: :string

    field :origin, :string
    timestamps(type: :utc_datetime)
  end
end
