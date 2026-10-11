defmodule Planner.LabelsTest do
  use Planner.DataCase, async: true

  alias Planner.Accounts.User
  alias Planner.Labels
  alias Planner.Labels.Label

  import Planner.AccountsFixtures
  import Planner.LabelsFixtures

  test "creation trims the name and assigns the server-side owner" do
    owner = user_fixture()
    other = user_fixture()
    assert {:ok, label} = Labels.create_label(owner, %{name: "  Work  ", user_id: other.id})
    assert label.name == "Work"
    assert label.user_id == owner.id

    assert {:ok, second} =
             Labels.create_label(owner, %{"name" => "Work", "user_id" => other.id})

    assert second.user_id == owner.id
    assert second.id != label.id
  end

  test "blank names are rejected without creating labels" do
    owner = user_fixture()

    for name <- [nil, "", "  ", "\n\t", " "] do
      assert {:error, changeset} = Labels.create_label(owner, %{name: name})
      assert errors_on(changeset).name == ["can't be blank"]
    end

    assert Labels.list_labels(owner) == []
  end

  test "listing and lookup expose only the supplied owner's labels" do
    owner = user_fixture()
    other = user_fixture()
    assert {:ok, own} = Labels.create_label(owner, %{name: "Own"})
    assert {:ok, foreign} = Labels.create_label(other, %{name: "Private"})
    assert Labels.list_labels(owner) == [own]
    assert Labels.get_label!(owner, own.id) == own
    assert_raise Ecto.NoResultsError, fn -> Labels.get_label!(owner, foreign.id) end
    assert_raise Ecto.NoResultsError, fn -> Labels.get_label!(owner, -1) end
  end

  test "outer rollback removes new labels and preserves the existing catalog" do
    owner = user_fixture()
    assert {:ok, existing} = Labels.create_label(owner, %{name: "Existing"})

    assert {:error, :cancelled} =
             Repo.transaction(fn ->
               assert {:ok, _} = Labels.create_label(owner, %{name: "New"})
               assert length(Labels.list_labels(owner)) == 2
               Repo.rollback(:cancelled)
             end)

    assert Labels.list_labels(owner) == [existing]
  end

  test "fixtures require an explicit owner and preserve user names" do
    owner = user_fixture()
    label = label_fixture(owner, %{name: "My English Label"})
    assert label.name == "My English Label"
    assert Labels.get_label!(owner, label.id) == label
  end

  test "a nonexistent owner returns a foreign key validation error" do
    assert {:error, changeset} = Labels.create_label(%User{id: -1}, %{name: "Orphan"})
    assert errors_on(changeset).user_id == ["does not exist"]
  end

  test "a label requires a persisted owner" do
    assert {:error, changeset} =
             Labels.create_label(%User{}, %{name: "Missing owner"})

    assert errors_on(changeset).user_id == ["can't be blank"]
    assert Repo.aggregate(Label, :count) == 0
  end
end
