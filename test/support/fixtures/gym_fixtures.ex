defmodule Housefit.GymFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Housefit.Gym` context.
  """

  @doc """
  Generate a unique member email.
  """
  def unique_member_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a member.
  """
  def member_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: unique_member_email(),
        first_name: "some first_name",
        is_active: true,
        last_name: "some last_name"
      })

    {:ok, member} = Housefit.Gym.create_member(scope, attrs)
    member
  end

  @doc """
  Generate a membership_type.
  """
  def membership_type_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        duration_months: 42,
        is_active: true,
        name: "some name",
        price: "120.5",
        session_count: 42,
        type: :time_based
      })

    {:ok, membership_type} = Housefit.Gym.create_membership_type(scope, attrs)
    membership_type
  end

  @doc """
  Generate a member_membership.
  """
  def member_membership_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        end_date: ~D[2025-05-29],
        notes: "some notes",
        payment_amount: "120.5",
        payment_date: ~D[2025-05-29],
        sessions_remaining: 42,
        sessions_total: 42,
        start_date: ~D[2025-05-29],
        status: :active
      })

    {:ok, member_membership} = Housefit.Gym.create_member_membership(scope, attrs)
    member_membership
  end

  @doc """
  Generate a gym_session.
  """
  def gym_session_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        check_in_time: ~U[2025-05-29 06:25:00Z],
        check_out_time: ~U[2025-05-29 06:25:00Z],
        notes: "some notes",
        session_date: ~D[2025-05-29]
      })

    {:ok, gym_session} = Housefit.Gym.create_gym_session(scope, attrs)
    gym_session
  end
end
