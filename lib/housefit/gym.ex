defmodule Housefit.Gym do
  @moduledoc """
  The Gym context.
  """

  import Ecto.Query, warn: false
  alias Housefit.Repo

  alias Housefit.Gym.Member
  alias Housefit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any member changes.

  The broadcasted messages match the pattern:

    * {:created, %Member{}}
    * {:updated, %Member{}}
    * {:deleted, %Member{}}

  """
  def subscribe_members(%Scope{} = _scope) do
    Phoenix.PubSub.subscribe(Housefit.PubSub, "user:admin:members")
  end

  defp broadcast(%Scope{} = _scope, message) do
    Phoenix.PubSub.broadcast(Housefit.PubSub, "user:admin:members", message)
  end

  @doc """
  Returns the list of all members.

  ## Examples

      iex> list_all_members()
      [%Member{}, ...]

  """
  def list_all_members() do
    Repo.all(Member)
  end

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members(scope)
      [%Member{}, ...]

  """
  def list_members(%Scope{} = scope) do
    Repo.all(from member in Member, where: member.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(%Scope{} = _scope, id) do
    Repo.get_by!(Member, id: id)
  end

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(%Scope{} = scope, attrs) do
    with {:ok, member = %Member{}} <-
           %Member{}
           |> Member.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, member})
      {:ok, member}
    end
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Scope{} = scope, %Member{} = member, attrs) do
    with {:ok, member = %Member{}} <-
           member
           |> Member.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, member})
      {:ok, member}
    end
  end

  @doc """
  Deletes a member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Scope{} = scope, %Member{} = member) do
    with {:ok, member = %Member{}} <- Repo.delete(member) do
      broadcast(scope, {:deleted, member})
      {:ok, member}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{data: %Member{}}

  """
  def change_member(%Scope{} = scope, %Member{} = member, attrs \\ %{}) do
    Member.changeset(member, attrs, scope)
  end

  alias Housefit.Gym.MembershipType
  alias Housefit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any membership_type changes.

  The broadcasted messages match the pattern:

    * {:created, %MembershipType{}}
    * {:updated, %MembershipType{}}
    * {:deleted, %MembershipType{}}

  """
  def subscribe_membership_types(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Housefit.PubSub, "user:#{key}:membership_types")
  end

  @doc """
  Returns the list of membership_types.

  ## Examples

      iex> list_membership_types(scope)
      [%MembershipType{}, ...]

  """
  def list_membership_types(%Scope{} = scope) do
    Repo.all(from membership_type in MembershipType, where: membership_type.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single membership_type.

  Raises `Ecto.NoResultsError` if the Membership type does not exist.

  ## Examples

      iex> get_membership_type!(123)
      %MembershipType{}

      iex> get_membership_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership_type!(%Scope{} = scope, id) do
    Repo.get_by!(MembershipType, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a membership_type.

  ## Examples

      iex> create_membership_type(%{field: value})
      {:ok, %MembershipType{}}

      iex> create_membership_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership_type(%Scope{} = scope, attrs) do
    with {:ok, membership_type = %MembershipType{}} <-
           %MembershipType{}
           |> MembershipType.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, membership_type})
      {:ok, membership_type}
    end
  end

  @doc """
  Updates a membership_type.

  ## Examples

      iex> update_membership_type(membership_type, %{field: new_value})
      {:ok, %MembershipType{}}

      iex> update_membership_type(membership_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership_type(%Scope{} = scope, %MembershipType{} = membership_type, attrs) do
    true = membership_type.user_id == scope.user.id

    with {:ok, membership_type = %MembershipType{}} <-
           membership_type
           |> MembershipType.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, membership_type})
      {:ok, membership_type}
    end
  end

  @doc """
  Deletes a membership_type.

  ## Examples

      iex> delete_membership_type(membership_type)
      {:ok, %MembershipType{}}

      iex> delete_membership_type(membership_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership_type(%Scope{} = scope, %MembershipType{} = membership_type) do
    true = membership_type.user_id == scope.user.id

    with {:ok, membership_type = %MembershipType{}} <-
           Repo.delete(membership_type) do
      broadcast(scope, {:deleted, membership_type})
      {:ok, membership_type}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership_type changes.

  ## Examples

      iex> change_membership_type(membership_type)
      %Ecto.Changeset{data: %MembershipType{}}

  """
  def change_membership_type(%Scope{} = scope, %MembershipType{} = membership_type, attrs \\ %{}) do
    true = membership_type.user_id == scope.user.id

    MembershipType.changeset(membership_type, attrs, scope)
  end

  alias Housefit.Gym.MemberMembership
  alias Housefit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any member_membership changes.

  The broadcasted messages match the pattern:

    * {:created, %MemberMembership{}}
    * {:updated, %MemberMembership{}}
    * {:deleted, %MemberMembership{}}

  """
  def subscribe_member_memberships(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Housefit.PubSub, "user:#{key}:member_memberships")
  end

  @doc """
  Returns the list of member_memberships.

  ## Examples

      iex> list_member_memberships(scope)
      [%MemberMembership{}, ...]

  """
  def list_member_memberships(%Scope{} = scope) do
    Repo.all(from member_membership in MemberMembership, where: member_membership.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single member_membership.

  Raises `Ecto.NoResultsError` if the Member membership does not exist.

  ## Examples

      iex> get_member_membership!(123)
      %MemberMembership{}

      iex> get_member_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member_membership!(%Scope{} = scope, id) do
    Repo.get_by!(MemberMembership, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a member_membership.

  ## Examples

      iex> create_member_membership(%{field: value})
      {:ok, %MemberMembership{}}

      iex> create_member_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member_membership(%Scope{} = scope, attrs) do
    with {:ok, member_membership = %MemberMembership{}} <-
           %MemberMembership{}
           |> MemberMembership.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, member_membership})
      {:ok, member_membership}
    end
  end

  @doc """
  Updates a member_membership.

  ## Examples

      iex> update_member_membership(member_membership, %{field: new_value})
      {:ok, %MemberMembership{}}

      iex> update_member_membership(member_membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member_membership(%Scope{} = scope, %MemberMembership{} = member_membership, attrs) do
    true = member_membership.user_id == scope.user.id

    with {:ok, member_membership = %MemberMembership{}} <-
           member_membership
           |> MemberMembership.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, member_membership})
      {:ok, member_membership}
    end
  end

  @doc """
  Deletes a member_membership.

  ## Examples

      iex> delete_member_membership(member_membership)
      {:ok, %MemberMembership{}}

      iex> delete_member_membership(member_membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member_membership(%Scope{} = scope, %MemberMembership{} = member_membership) do
    true = member_membership.user_id == scope.user.id

    with {:ok, member_membership = %MemberMembership{}} <-
           Repo.delete(member_membership) do
      broadcast(scope, {:deleted, member_membership})
      {:ok, member_membership}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member_membership changes.

  ## Examples

      iex> change_member_membership(member_membership)
      %Ecto.Changeset{data: %MemberMembership{}}

  """
  def change_member_membership(%Scope{} = scope, %MemberMembership{} = member_membership, attrs \\ %{}) do
    true = member_membership.user_id == scope.user.id

    MemberMembership.changeset(member_membership, attrs, scope)
  end

  alias Housefit.Gym.GymSession
  alias Housefit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any gym_session changes.

  The broadcasted messages match the pattern:

    * {:created, %GymSession{}}
    * {:updated, %GymSession{}}
    * {:deleted, %GymSession{}}

  """
  def subscribe_gym_sessions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Housefit.PubSub, "user:#{key}:gym_sessions")
  end

  @doc """
  Returns the list of gym_sessions.

  ## Examples

      iex> list_gym_sessions(scope)
      [%GymSession{}, ...]

  """
  def list_gym_sessions(%Scope{} = scope) do
    Repo.all(from gym_session in GymSession, where: gym_session.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single gym_session.

  Raises `Ecto.NoResultsError` if the Gym session does not exist.

  ## Examples

      iex> get_gym_session!(123)
      %GymSession{}

      iex> get_gym_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gym_session!(%Scope{} = scope, id) do
    Repo.get_by!(GymSession, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a gym_session.

  ## Examples

      iex> create_gym_session(%{field: value})
      {:ok, %GymSession{}}

      iex> create_gym_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gym_session(%Scope{} = scope, attrs) do
    with {:ok, gym_session = %GymSession{}} <-
           %GymSession{}
           |> GymSession.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, gym_session})
      {:ok, gym_session}
    end
  end

  @doc """
  Updates a gym_session.

  ## Examples

      iex> update_gym_session(gym_session, %{field: new_value})
      {:ok, %GymSession{}}

      iex> update_gym_session(gym_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gym_session(%Scope{} = scope, %GymSession{} = gym_session, attrs) do
    true = gym_session.user_id == scope.user.id

    with {:ok, gym_session = %GymSession{}} <-
           gym_session
           |> GymSession.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, gym_session})
      {:ok, gym_session}
    end
  end

  @doc """
  Deletes a gym_session.

  ## Examples

      iex> delete_gym_session(gym_session)
      {:ok, %GymSession{}}

      iex> delete_gym_session(gym_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gym_session(%Scope{} = scope, %GymSession{} = gym_session) do
    true = gym_session.user_id == scope.user.id

    with {:ok, gym_session = %GymSession{}} <-
           Repo.delete(gym_session) do
      broadcast(scope, {:deleted, gym_session})
      {:ok, gym_session}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gym_session changes.

  ## Examples

      iex> change_gym_session(gym_session)
      %Ecto.Changeset{data: %GymSession{}}

  """
  def change_gym_session(%Scope{} = scope, %GymSession{} = gym_session, attrs \\ %{}) do
    true = gym_session.user_id == scope.user.id

    GymSession.changeset(gym_session, attrs, scope)
  end
end
