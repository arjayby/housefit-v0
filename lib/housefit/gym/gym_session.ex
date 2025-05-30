defmodule Housefit.Gym.GymSession do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "gym_sessions" do
    field :check_in_time, :utc_datetime
    field :check_out_time, :utc_datetime
    field :session_date, :date
    field :notes, :string
    field :member_id, :binary_id
    field :membership_id, :binary_id
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gym_session, attrs, user_scope) do
    gym_session
    |> cast(attrs, [:check_in_time, :check_out_time, :session_date, :notes, :user_id])
    |> validate_required([:check_in_time, :session_date, :notes, :user_id])
    |> put_change(:user_id, user_scope.user.id)
  end
end
