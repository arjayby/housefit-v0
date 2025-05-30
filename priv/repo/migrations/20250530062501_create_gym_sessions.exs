defmodule Housefit.Repo.Migrations.CreateGymSessions do
  use Ecto.Migration

  def change do
    create table(:gym_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :check_in_time, :utc_datetime
      add :check_out_time, :utc_datetime
      add :session_date, :date
      add :notes, :text
      add :member_id, references(:members, on_delete: :nothing, type: :binary_id)
      add :membership_id, references(:member_memberships, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:gym_sessions, [:user_id])

    create index(:gym_sessions, [:member_id])
    create index(:gym_sessions, [:membership_id])
  end
end
