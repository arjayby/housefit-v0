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
end
