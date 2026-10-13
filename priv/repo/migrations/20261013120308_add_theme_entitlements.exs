defmodule Planner.Repo.Migrations.AddThemeEntitlements do
  use Ecto.Migration

  def change do
    create table(:themes, primary_key: false) do
      add :code, :string, primary_key: true
    end

    execute "INSERT INTO themes (code) VALUES ('planner'), ('planner_dark')", "DELETE FROM themes"

    create table(:theme_entitlements) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :theme_code, references(:themes, column: :code, type: :string), null: false
      add :origin, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:theme_entitlements, [:user_id, :theme_code])

    create constraint(:theme_entitlements, :theme_entitlements_origin_required,
             check: "origin <> ''"
           )

    alter table(:users) do
      add :theme_code, references(:themes, column: :code, type: :string),
        default: "planner",
        null: false
    end

    execute """
            INSERT INTO theme_entitlements (user_id, theme_code, origin, inserted_at, updated_at)
            SELECT users.id, themes.code, 'free', NOW(), NOW()
            FROM users CROSS JOIN themes WHERE users.email IS NOT NULL
            ON CONFLICT (user_id, theme_code) DO NOTHING
            """,
            "DELETE FROM theme_entitlements"
  end
end
