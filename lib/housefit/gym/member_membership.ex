defmodule Housefit.Gym.MemberMembership do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "member_memberships" do
    field :start_date, :date
    field :end_date, :date
    field :sessions_remaining, :integer
    field :sessions_total, :integer
    field :status, Ecto.Enum, values: [:active, :expired, :suspended]
    field :payment_amount, :decimal
    field :payment_date, :date
    field :notes, :string
    field :member_id, :binary_id
    field :membership_type_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(member_membership, attrs, user_scope) do
    member_membership
    |> cast(attrs, [:start_date, :end_date, :sessions_remaining, :sessions_total, :status, :payment_amount, :payment_date, :notes])
    |> validate_required([:start_date, :end_date, :sessions_remaining, :sessions_total, :status, :payment_amount, :payment_date, :notes])
    |> put_change(:user_id, user_scope.user.id)
  end
end
