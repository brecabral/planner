defmodule Planner.AccountsTest do
  use Planner.DataCase, async: true

  alias Planner.Accounts
  alias Planner.Accounts.User

  import Planner.AccountsFixtures

  test "preparation persists the default user and preserves its identity and timestamps" do
    user = Accounts.ensure_default_user!()
    assert user.identifier == "default"
    assert user.id
    assert Accounts.get_default_user!() == user
    assert Accounts.ensure_default_user!() == user
    assert Repo.aggregate(User, :count) == 1
  end

  test "lookup requires preparation and does not silently create a user" do
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_default_user!() end
    assert Repo.aggregate(User, :count) == 0
  end

  test "seeds create a missing default user exactly once" do
    Code.eval_file("priv/repo/seeds.exs")
    default = Accounts.get_default_user!()
    Code.eval_file("priv/repo/seeds.exs")
    assert Accounts.get_default_user!() == default
    assert Repo.aggregate(User, :count) == 1
  end

  test "running seeds twice preserves the existing default user and other identities" do
    default =
      user_fixture(%{identifier: "default"})
      |> Ecto.Changeset.change(updated_at: ~U[2020-01-01 00:00:00Z])
      |> Repo.update!()

    other = user_fixture()

    for _ <- 1..2, do: Code.eval_file("priv/repo/seeds.exs")

    assert Accounts.get_default_user!() == default
    assert Repo.get!(User, other.id) == other
    assert Repo.aggregate(User, :count) == 2
  end

  test "fixtures create independent persisted users without global seeds" do
    first = user_fixture()
    second = user_fixture()
    assert first.id != second.id
    assert first.identifier != second.identifier
    assert Repo.get!(User, first.id) == first
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_default_user!() end
  end

  test "user identity requires a unique nonempty identifier" do
    assert {:error, blank} = %User{} |> User.changeset(%{}) |> Repo.insert()
    assert errors_on(blank) == %{identifier: ["can't be blank"]}

    user_fixture(%{identifier: "default"})

    assert {:error, duplicate} =
             %User{} |> User.changeset(%{identifier: "default"}) |> Repo.insert()

    assert errors_on(duplicate) == %{identifier: ["has already been taken"]}
  end
end
