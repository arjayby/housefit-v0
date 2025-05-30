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
end
