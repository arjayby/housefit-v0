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
    field :is_active, :boolean, default: true
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership_type, attrs, user_scope) do
    membership_type
    |> cast(attrs, [
      :name,
      :type,
      :duration_months,
      :session_count,
      :price,
      :description
    ])
    |> validate_required([:name, :type, :price, :description])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_number(:duration_months, greater_than: 0)
    |> validate_number(:session_count, greater_than: 0)
    |> validate_number(:price, greater_than: 0)
    |> validate_type()
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_type(changeset) do
    case get_field(changeset, :type) do
      :time_based ->
        validate_required(changeset, [:duration_months])

      :session_based ->
        validate_required(changeset, [:session_count])

      _ ->
        changeset
    end
  end
end
