defmodule Housefit.Repo.Migrations.CreateMembershipTypes do
  use Ecto.Migration

  def change do
    create table(:membership_types, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :duration_months, :integer
      add :session_count, :integer
      add :price, :decimal
      add :description, :text
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:membership_types, [:user_id])
  end
end
