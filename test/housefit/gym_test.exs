defmodule Housefit.GymTest do
  use Housefit.DataCase

  alias Housefit.Gym

  describe "members" do
    alias Housefit.Gym.Member

    import Housefit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Housefit.GymFixtures

    @invalid_attrs %{email: nil, first_name: nil, last_name: nil, is_active: nil}

    test "list_members/1 returns all scoped members" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member = member_fixture(scope)
      other_member = member_fixture(other_scope)
      assert Gym.list_members(scope) == [member]
      assert Gym.list_members(other_scope) == [other_member]
    end

    test "get_member!/2 returns the member with given id" do
      scope = user_scope_fixture()
      member = member_fixture(scope)
      other_scope = user_scope_fixture()
      assert Gym.get_member!(scope, member.id) == member
      assert_raise Ecto.NoResultsError, fn -> Gym.get_member!(other_scope, member.id) end
    end

    test "create_member/2 with valid data creates a member" do
      valid_attrs = %{email: "some email", first_name: "some first_name", last_name: "some last_name", is_active: true}
      scope = user_scope_fixture()

      assert {:ok, %Member{} = member} = Gym.create_member(scope, valid_attrs)
      assert member.email == "some email"
      assert member.first_name == "some first_name"
      assert member.last_name == "some last_name"
      assert member.is_active == true
      assert member.user_id == scope.user.id
    end

    test "create_member/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Gym.create_member(scope, @invalid_attrs)
    end

    test "update_member/3 with valid data updates the member" do
      scope = user_scope_fixture()
      member = member_fixture(scope)
      update_attrs = %{email: "some updated email", first_name: "some updated first_name", last_name: "some updated last_name", is_active: false}

      assert {:ok, %Member{} = member} = Gym.update_member(scope, member, update_attrs)
      assert member.email == "some updated email"
      assert member.first_name == "some updated first_name"
      assert member.last_name == "some updated last_name"
      assert member.is_active == false
    end

    test "update_member/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member = member_fixture(scope)

      assert_raise MatchError, fn ->
        Gym.update_member(other_scope, member, %{})
      end
    end

    test "update_member/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      member = member_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Gym.update_member(scope, member, @invalid_attrs)
      assert member == Gym.get_member!(scope, member.id)
    end

    test "delete_member/2 deletes the member" do
      scope = user_scope_fixture()
      member = member_fixture(scope)
      assert {:ok, %Member{}} = Gym.delete_member(scope, member)
      assert_raise Ecto.NoResultsError, fn -> Gym.get_member!(scope, member.id) end
    end

    test "delete_member/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member = member_fixture(scope)
      assert_raise MatchError, fn -> Gym.delete_member(other_scope, member) end
    end

    test "change_member/2 returns a member changeset" do
      scope = user_scope_fixture()
      member = member_fixture(scope)
      assert %Ecto.Changeset{} = Gym.change_member(scope, member)
    end
  end
end
