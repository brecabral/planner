defmodule Planner.ThemesTest do
  use Planner.DataCase, async: true
  import Planner.AccountsFixtures
  alias Planner.{Accounts, Themes}
  alias Planner.Accounts.{Scope, User}

  test "registration prepares both free themes once and defaults to light" do
    user = authenticated_user_fixture()
    scope = Scope.for_user(user)
    assert Repo.reload!(user).theme_code == "planner"
    assert {:ok, _} = Themes.prepare_user(user)
    assert {:ok, _} = Themes.prepare_user(user)
    assert Enum.map(Themes.list_available_themes(scope), & &1.code) == ["planner", "planner_dark"]

    assert Repo.query!("SELECT origin FROM theme_entitlements WHERE user_id = $1", [user.id]).rows ==
             [["free"], ["free"]]
  end

  test "selection belongs to the authenticated scope and rejects forged ownership" do
    user = authenticated_user_fixture()
    other = authenticated_user_fixture()
    scope = Scope.for_user(user)
    assert {:ok, selected} = Themes.select_theme(scope, %{"theme_code" => "planner_dark"})
    assert selected.theme_code == "planner_dark"
    assert Repo.reload!(other).theme_code == "planner"

    assert {:error, :invalid_selection} =
             Themes.select_theme(scope, %{"theme_code" => "planner", "user_id" => other.id})

    assert {:error, :unavailable_theme} = Themes.select_theme(scope, %{"theme_code" => "unknown"})
    assert Repo.reload!(user).theme_code == "planner_dark"
    assert {:error, :unauthenticated} = Themes.select_theme(nil, %{"theme_code" => "planner"})
  end

  test "a known theme without an entitlement cannot be selected or granted by payload" do
    user = authenticated_user_fixture()

    Repo.query!(
      "DELETE FROM theme_entitlements WHERE user_id = $1 AND theme_code = 'planner_dark'",
      [user.id]
    )

    assert {:error, :unavailable_theme} =
             Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})

    assert Repo.reload!(user).theme_code == "planner"
    assert length(Themes.list_available_themes(Scope.for_user(user))) == 1
  end

  test "legacy preparation does not create login identity or entitlements" do
    user = Accounts.ensure_default_user!()
    assert {:error, :unauthenticated} = Themes.prepare_user(user)
    assert Repo.reload!(user).email == nil
    assert Themes.list_available_themes(Scope.for_user(user)) == []
  end

  test "invalid registration leaves no partial user or entitlement" do
    count = Repo.aggregate(User, :count)
    assert {:error, _} = Accounts.register_user(%{email: "invalid"})
    assert Repo.aggregate(User, :count) == count
  end

  test "a deleted account cannot be prepared or selected through a stale scope" do
    user = authenticated_user_fixture()
    Repo.delete!(user)
    assert {:error, :unauthenticated} = Themes.prepare_user(user)

    assert {:error, :unauthenticated} =
             Themes.select_theme(Scope.for_user(user), %{"theme_code" => "planner_dark"})
  end

  test "registration cannot forge selection or entitlements" do
    {:ok, user} =
      Accounts.register_user(%{
        email: unique_user_email(),
        theme_code: "planner_dark",
        user_id: -1,
        origin: "paid"
      })

    assert user.theme_code == "planner"

    assert Enum.map(Themes.list_available_themes(Scope.for_user(user)), & &1.code) ==
             ["planner", "planner_dark"]

    assert {:error, :invalid_selection} =
             Themes.select_theme(Scope.for_user(user), %{
               "theme_code" => "planner_dark",
               :user_id => -1
             })
  end
end
