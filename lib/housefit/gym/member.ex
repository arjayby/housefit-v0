defmodule Housefit.Gym.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "members" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :is_active, :boolean, default: false
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member, attrs, user_scope) do
    member
    |> cast(attrs, [:email, :first_name, :last_name, :is_active])
    |> validate_required([:email, :first_name, :last_name, :is_active])
    |> unique_constraint(:email)
    |> put_change(:user_id, user_scope.user.id)
  end
end
