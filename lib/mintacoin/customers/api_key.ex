defmodule Mintacoin.ApiKey do
  @moduledoc """
  Ecto schema for ApiKeys
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.{Changeset, UUID}
  alias Mintacoin.Account

  @type api_key :: String.t()
  @type encrypted_api_key :: String.t()
  @type id :: UUID.t()
  @type name :: String.t()

  @type t :: %__MODULE__{
          name: name(),
          account_id: id(),
          encrypted_api_key: encrypted_api_key(),
          api_key: api_key()
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "api_keys" do
    field(:name, :string)
    field(:encrypted_api_key, :string)
    field(:api_key, :string, virtual: true)

    belongs_to(:account, Account, type: :binary_id)

    timestamps()
  end

  @spec changeset(api_key :: %__MODULE__{}, changes :: map()) :: Changeset.t()
  def changeset(api_key, changes) do
    cast(api_key, changes, [:encrypted_api_key, :name])
  end

  @spec create_changeset(api_key :: %__MODULE__{}, attrs :: map()) :: Changeset.t()
  def create_changeset(api_key, attrs) do
    api_key
    |> cast(attrs, [:account_id, :api_key, :encrypted_api_key, :name])
    |> validate_required([:account_id, :api_key, :encrypted_api_key, :name])
    |> foreign_key_constraint(:account_id)
    |> unique_constraint([:account_id, :api_key], name: :account_id_api_key_index)
  end
end
