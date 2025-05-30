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
    |> cast(attrs, [
      :start_date,
      :end_date,
      :sessions_remaining,
      :sessions_total,
      :status,
      :payment_amount,
      :payment_date,
      :notes,
      :member_id,
      :membership_type_id
    ])
    |> validate_required([
      :status,
      :payment_amount,
      :payment_date,
      :member_id,
      :membership_type_id
    ])
    |> validate_start_end_date_required()
    |> validate_sessions_required()
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_start_end_date_required(changeset) do
    case get_field(changeset, :membership_type_id) do
      membership_type_id when membership_type_id in ["time_based"] ->
        validate_required(changeset, [:start_date, :end_date])
        validate_start_end_date(changeset)

      _ ->
        changeset
    end
  end

  defp validate_start_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    case start_date do
      start_date when start_date < end_date ->
        changeset

      _ ->
        add_error(changeset, :start_date, "Start date must be less than end date")
    end
  end

  def validate_sessions_required(changeset) do
    case get_field(changeset, :membership_type_id) do
      membership_type_id when membership_type_id in ["session_based"] ->
        validate_required(changeset, [:sessions_remaining, :sessions_total])
        validate_sessions_remaining(changeset)

      _ ->
        changeset
    end
  end

  defp validate_sessions_remaining(changeset) do
    sessions_remaining = get_field(changeset, :sessions_remaining)
    sessions_total = get_field(changeset, :sessions_total)

    case sessions_remaining do
      remaining when remaining <= sessions_total ->
        changeset

      _ ->
        add_error(
          changeset,
          :sessions_remaining,
          "Sessions remaining must be less than sessions total"
        )
    end
  end
end
