defmodule Mintacoin.Customer do
  @moduledoc """
  Ecto schema for customers
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.{Changeset, UUID}
  alias Mintacoin.Account

  @type id :: UUID.t()
  @type name :: String.t()
  @type encrypted_api_key :: String.t()
  @type api_key :: String.t()

  @type t :: %__MODULE__{
          name: name(),
          account_id: id(),
          encrypted_api_key: encrypted_api_key(),
          api_key: api_key()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "customers" do
    field(:name, :string)
    field(:encrypted_api_key, :string)
    field(:api_key, :string, virtual: true)

    belongs_to(:account, Account, type: :binary_id)

    timestamps()
  end

  @spec changeset(customer :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(customer, changes) do
    cast(customer, changes, [:encrypted_api_key, :name])
  end

  @spec create_changeset(customer :: %__MODULE__{}, attrs :: map()) :: Changeset.t()
  def create_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:account_id, :api_key, :encrypted_api_key, :name])
    |> validate_required([:account_id, :api_key, :encrypted_api_key, :name])
    |> foreign_key_constraint(:account_id)
    |> unique_constraint(:account_id, name: :account_id_api_key_index)
  end
end
