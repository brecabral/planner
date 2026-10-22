defmodule Planner.AccountsAuthTest do
  use Planner.DataCase, async: true

  alias Planner.Accounts

  test "registration normalizes email and does not inherit the legacy identity" do
    assert {:ok, user} = Accounts.register_user(%{email: "  Alice@Example.COM  "})
    assert user.email == "alice@example.com"
    assert user.identifier == nil
    assert {:error, changeset} = Accounts.register_user(%{email: "ALICE@example.com"})
    assert errors_on(changeset).email == ["has already been taken"]
  end

  import Planner.AccountsFixtures
  alias Planner.Accounts.UserToken
  alias Planner.Repo

  test "confirmation consumes a hashed token and revokes all previous tokens" do
    user = unconfirmed_user_fixture()
    session = Accounts.generate_user_session_token(user)
    {token, hash} = generate_user_magic_link_token(user)
    {other, _} = generate_user_magic_link_token(user)
    assert hash == :crypto.hash(:sha256, Base.url_decode64!(token, padding: false))
    assert {:ok, {confirmed, revoked}} = Accounts.login_user_by_magic_link(token)
    assert confirmed.confirmed_at
    assert length(revoked) == 3
    refute Accounts.get_user_by_session_token(session)
    assert {:error, :not_found} = Accounts.login_user_by_magic_link(token)
    assert {:error, :not_found} = Accounts.login_user_by_magic_link(other)
  end

  test "invalid, expired and wrong-recipient links cannot authenticate" do
    user = unconfirmed_user_fixture()
    {token, hash} = generate_user_magic_link_token(user)
    offset_user_token(hash, -15, :minute)
    assert {:error, :not_found} = Accounts.login_user_by_magic_link(token)
    assert {:error, :not_found} = Accounts.login_user_by_magic_link("invalid!")
    {token, hash} = generate_user_magic_link_token(user)

    Repo.get_by!(UserToken, token: hash)
    |> Ecto.Changeset.change(sent_to: "another@example.com")
    |> Repo.update!()

    assert {:error, :not_found} = Accounts.login_user_by_magic_link(token)
    refute Repo.reload!(user).confirmed_at
  end

  test "confirmed account consumes only the used login link" do
    user = authenticated_user_fixture()
    session = Accounts.generate_user_session_token(user)
    {token, _} = generate_user_magic_link_token(user)
    assert {:ok, {same_user, []}} = Accounts.login_user_by_magic_link(token)
    assert same_user.id == user.id
    assert Accounts.get_user_by_session_token(session)
    assert {:error, :not_found} = Accounts.login_user_by_magic_link(token)
  end

  test "legacy identity and ownership remain intact alongside new accounts" do
    legacy = Accounts.ensure_default_user!()
    first = authenticated_user_fixture()
    second = authenticated_user_fixture()
    assert Repo.reload!(legacy) == legacy
    assert_raise FunctionClauseError, fn -> Accounts.generate_user_session_token(legacy) end
    assert is_nil(legacy.email)
    assert first.id != legacy.id and second.id != legacy.id and first.id != second.id
  end
end
