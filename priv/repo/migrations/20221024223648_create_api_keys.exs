defmodule Mintacoin.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string, null: false)
      add(:account_id, references(:accounts, type: :uuid), null: false)
      add(:encrypted_api_key, :string, null: false)

      timestamps()
    end

    create(unique_index(:customers, :account_id, name: :account_id_api_key_index))
  end
end
