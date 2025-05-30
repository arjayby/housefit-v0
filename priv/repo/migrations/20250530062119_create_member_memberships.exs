defmodule Housefit.Repo.Migrations.CreateMemberMemberships do
  use Ecto.Migration

  def change do
    create table(:member_memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_date, :date
      add :end_date, :date
      add :sessions_remaining, :integer
      add :sessions_total, :integer
      add :status, :string
      add :payment_amount, :decimal
      add :payment_date, :date
      add :notes, :text
      add :member_id, references(:members, on_delete: :nothing, type: :binary_id)
      add :membership_type_id, references(:membership_types, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:member_memberships, [:user_id])

    create index(:member_memberships, [:member_id])
    create index(:member_memberships, [:membership_type_id])
  end
end
