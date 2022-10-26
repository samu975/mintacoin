defmodule Mintacoin.ApiKeys do
  @moduledoc """
  This module is the responsible to manege to customers authentication
  """

  alias Phoenix.Token
  alias Ecto.{Changeset, UUID}
  alias Mintacoin.{Account, Accounts.Cipher, ApiKey, Repo}

  @type api_key :: ApiKey.t()
  @type error :: :expired | :invalid | :missing | :encryption_error | Changeset.t()
  @type id :: UUID.t()
  @type params :: map()
  @type secret_base :: String.t()
  @type signing_salt :: String.t()
  @type token :: String.t()
  @type token_age :: integer()
  @type token_data :: map()

  @token_age 7 * 24 * 3600

  @spec create(params :: params()) :: {:ok, api_key()} | {:error, error()}
  def create(%{account: %Account{id: account_id}, name: name}) do
    sign_token = sign_token(%{account_id: account_id})
    {:ok, encrypted_token} = Cipher.encrypt_with_system_key(sign_token)

    %ApiKey{}
    |> ApiKey.create_changeset(%{
      name: name,
      account_id: account_id,
      encrypted_api_key: encrypted_token,
      api_key: sign_token
    })
    |> Repo.insert()
  end

  @spec update(api_key_id :: id(), params :: params()) :: {:ok, api_key()} | {:error, error()}
  def update(id, changes) do
    ApiKey
    |> Repo.get(id)
    |> ApiKey.changeset(changes)
    |> Repo.update()
  end

  @spec retrieve_by_id(api_key_id :: id()) :: {:ok, api_key() | nil}
  def retrieve_by_id(id), do: {:ok, Repo.get(ApiKey, id)}

  @spec verify_customer(token :: token()) :: {:ok, token_data()} | {:error, error()}
  def verify_customer(token) do
    secret_key_base = secret_key_base()
    signing_salt = signing_salt()

    Token.verify(secret_key_base, signing_salt, token)
  end

  @spec sign_token(data :: token_data(), age :: token_age()) :: token()
  defp sign_token(data, age \\ @token_age) do
    secret_key_base = secret_key_base()
    signing_salt = signing_salt()

    Token.sign(secret_key_base, signing_salt, data, max_age: age)
  end

  @spec secret_key_base() :: secret_base()
  defp secret_key_base, do: Application.get_env(:mintacoin, :secret_key_base)

  @spec signing_salt() :: signing_salt()
  defp signing_salt, do: Application.get_env(:mintacoin, :signing_salt)
end
