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

  describe "membership_types" do
    alias Housefit.Gym.MembershipType

    import Housefit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Housefit.GymFixtures

    @invalid_attrs %{name: nil, type: nil, description: nil, duration_months: nil, session_count: nil, price: nil, is_active: nil}

    test "list_membership_types/1 returns all scoped membership_types" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      other_membership_type = membership_type_fixture(other_scope)
      assert Gym.list_membership_types(scope) == [membership_type]
      assert Gym.list_membership_types(other_scope) == [other_membership_type]
    end

    test "get_membership_type!/2 returns the membership_type with given id" do
      scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      other_scope = user_scope_fixture()
      assert Gym.get_membership_type!(scope, membership_type.id) == membership_type
      assert_raise Ecto.NoResultsError, fn -> Gym.get_membership_type!(other_scope, membership_type.id) end
    end

    test "create_membership_type/2 with valid data creates a membership_type" do
      valid_attrs = %{name: "some name", type: :time_based, description: "some description", duration_months: 42, session_count: 42, price: "120.5", is_active: true}
      scope = user_scope_fixture()

      assert {:ok, %MembershipType{} = membership_type} = Gym.create_membership_type(scope, valid_attrs)
      assert membership_type.name == "some name"
      assert membership_type.type == :time_based
      assert membership_type.description == "some description"
      assert membership_type.duration_months == 42
      assert membership_type.session_count == 42
      assert membership_type.price == Decimal.new("120.5")
      assert membership_type.is_active == true
      assert membership_type.user_id == scope.user.id
    end

    test "create_membership_type/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Gym.create_membership_type(scope, @invalid_attrs)
    end

    test "update_membership_type/3 with valid data updates the membership_type" do
      scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      update_attrs = %{name: "some updated name", type: :session_based, description: "some updated description", duration_months: 43, session_count: 43, price: "456.7", is_active: false}

      assert {:ok, %MembershipType{} = membership_type} = Gym.update_membership_type(scope, membership_type, update_attrs)
      assert membership_type.name == "some updated name"
      assert membership_type.type == :session_based
      assert membership_type.description == "some updated description"
      assert membership_type.duration_months == 43
      assert membership_type.session_count == 43
      assert membership_type.price == Decimal.new("456.7")
      assert membership_type.is_active == false
    end

    test "update_membership_type/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)

      assert_raise MatchError, fn ->
        Gym.update_membership_type(other_scope, membership_type, %{})
      end
    end

    test "update_membership_type/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Gym.update_membership_type(scope, membership_type, @invalid_attrs)
      assert membership_type == Gym.get_membership_type!(scope, membership_type.id)
    end

    test "delete_membership_type/2 deletes the membership_type" do
      scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      assert {:ok, %MembershipType{}} = Gym.delete_membership_type(scope, membership_type)
      assert_raise Ecto.NoResultsError, fn -> Gym.get_membership_type!(scope, membership_type.id) end
    end

    test "delete_membership_type/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      assert_raise MatchError, fn -> Gym.delete_membership_type(other_scope, membership_type) end
    end

    test "change_membership_type/2 returns a membership_type changeset" do
      scope = user_scope_fixture()
      membership_type = membership_type_fixture(scope)
      assert %Ecto.Changeset{} = Gym.change_membership_type(scope, membership_type)
    end
  end

  describe "member_memberships" do
    alias Housefit.Gym.MemberMembership

    import Housefit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Housefit.GymFixtures

    @invalid_attrs %{status: nil, start_date: nil, end_date: nil, sessions_remaining: nil, sessions_total: nil, payment_amount: nil, payment_date: nil, notes: nil}

    test "list_member_memberships/1 returns all scoped member_memberships" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      other_member_membership = member_membership_fixture(other_scope)
      assert Gym.list_member_memberships(scope) == [member_membership]
      assert Gym.list_member_memberships(other_scope) == [other_member_membership]
    end

    test "get_member_membership!/2 returns the member_membership with given id" do
      scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      other_scope = user_scope_fixture()
      assert Gym.get_member_membership!(scope, member_membership.id) == member_membership
      assert_raise Ecto.NoResultsError, fn -> Gym.get_member_membership!(other_scope, member_membership.id) end
    end

    test "create_member_membership/2 with valid data creates a member_membership" do
      valid_attrs = %{status: :active, start_date: ~D[2025-05-29], end_date: ~D[2025-05-29], sessions_remaining: 42, sessions_total: 42, payment_amount: "120.5", payment_date: ~D[2025-05-29], notes: "some notes"}
      scope = user_scope_fixture()

      assert {:ok, %MemberMembership{} = member_membership} = Gym.create_member_membership(scope, valid_attrs)
      assert member_membership.status == :active
      assert member_membership.start_date == ~D[2025-05-29]
      assert member_membership.end_date == ~D[2025-05-29]
      assert member_membership.sessions_remaining == 42
      assert member_membership.sessions_total == 42
      assert member_membership.payment_amount == Decimal.new("120.5")
      assert member_membership.payment_date == ~D[2025-05-29]
      assert member_membership.notes == "some notes"
      assert member_membership.user_id == scope.user.id
    end

    test "create_member_membership/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Gym.create_member_membership(scope, @invalid_attrs)
    end

    test "update_member_membership/3 with valid data updates the member_membership" do
      scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      update_attrs = %{status: :expired, start_date: ~D[2025-05-30], end_date: ~D[2025-05-30], sessions_remaining: 43, sessions_total: 43, payment_amount: "456.7", payment_date: ~D[2025-05-30], notes: "some updated notes"}

      assert {:ok, %MemberMembership{} = member_membership} = Gym.update_member_membership(scope, member_membership, update_attrs)
      assert member_membership.status == :expired
      assert member_membership.start_date == ~D[2025-05-30]
      assert member_membership.end_date == ~D[2025-05-30]
      assert member_membership.sessions_remaining == 43
      assert member_membership.sessions_total == 43
      assert member_membership.payment_amount == Decimal.new("456.7")
      assert member_membership.payment_date == ~D[2025-05-30]
      assert member_membership.notes == "some updated notes"
    end

    test "update_member_membership/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)

      assert_raise MatchError, fn ->
        Gym.update_member_membership(other_scope, member_membership, %{})
      end
    end

    test "update_member_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Gym.update_member_membership(scope, member_membership, @invalid_attrs)
      assert member_membership == Gym.get_member_membership!(scope, member_membership.id)
    end

    test "delete_member_membership/2 deletes the member_membership" do
      scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      assert {:ok, %MemberMembership{}} = Gym.delete_member_membership(scope, member_membership)
      assert_raise Ecto.NoResultsError, fn -> Gym.get_member_membership!(scope, member_membership.id) end
    end

    test "delete_member_membership/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      assert_raise MatchError, fn -> Gym.delete_member_membership(other_scope, member_membership) end
    end

    test "change_member_membership/2 returns a member_membership changeset" do
      scope = user_scope_fixture()
      member_membership = member_membership_fixture(scope)
      assert %Ecto.Changeset{} = Gym.change_member_membership(scope, member_membership)
    end
  end
end
