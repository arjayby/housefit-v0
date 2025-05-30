defmodule Housefit.Gym.MembershipType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "membership_types" do
    field :name, :string
    field :type, Ecto.Enum, values: [:time_based, :session_based]
    field :duration_months, :integer
    field :session_count, :integer
    field :price, :decimal
    field :description, :string
    field :is_active, :boolean, default: false
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership_type, attrs, user_scope) do
    membership_type
    |> cast(attrs, [:name, :type, :duration_months, :session_count, :price, :description, :is_active])
    |> validate_required([:name, :type, :duration_months, :session_count, :price, :description, :is_active])
    |> put_change(:user_id, user_scope.user.id)
  end
end
