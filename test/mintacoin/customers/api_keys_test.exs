defmodule Mintacoin.Customers.ApiKeysTest do
  @moduledoc """
  This module is used to group common tests for api key functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1]

  alias Ecto.{Adapters.SQL.Sandbox, Changeset}
  alias Mintacoin.{Account, ApiKey, ApiKeys}

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    Application.put_env(
      :mintacoin,
      :secret_key_base,
      "TsKzdh4cyS0eYXjISZmZzlbOriQvzIXf5cj6mX7OfUFLLq2RdzuH2+uCg3+3jRNe"
    )

    Application.put_env(:mintacoin, :signing_salt, "g6gVDdqHZeWeLiH1i5b7QlhZGNr2PaLo")

    on_exit(fn ->
      Application.delete_env(:mintacoin, :secret_key_base)
      Application.delete_env(:mintacoin, :signing_salt)
    end)

    account = insert(:account)
    api_key = insert(:api_key)

    %{
      account: account,
      api_key: api_key,
      name: "Customer",
      new_name: "Mintacoin",
      new_encrypted_api_key:
        "haooplkURD87vqXeq3svsKRxbokArcRhvoMnnbNbZqQRYmzrjI+Jn3gVmALejFwxgqRpbU9FmCDc5a6U3x4jW4mFqXr3I9mMoBeQS8HmLazHfDTytqhK8mCOdWkmnk7gDfbO167daVw2kK90E5jleYSY9Fcq3szryQPk5G5psP5SMkma9S9Gke+ail411PSbb/HUytuoI5hbqzyk8NbrXr3CV2w87mtcokIAznjx8Tk",
      not_existing_uuid: "d9cb83d6-05f5-4557-b5d0-9e1728c42091"
    }
  end

  describe "create/1" do
    test "with valid params", %{account: %{id: account_id} = account, name: name} do
      {:ok, %ApiKey{name: ^name, account_id: ^account_id}} =
        ApiKeys.create(%{account: account, name: name})
    end

    test "with invalid account", %{name: name, not_existing_uuid: not_existing_uuid} do
      {:error,
       %Changeset{
         errors: [
           {:account_id, {"does not exist", _detail}}
           | _tail
         ]
       }} = ApiKeys.create(%{account: %Account{id: not_existing_uuid}, name: name})
    end

    test "with invalid name", %{account: account} do
      {:error,
       %Changeset{
         errors: [
           {:name, {"is invalid", _detail}}
           | _tail
         ]
       }} = ApiKeys.create(%{account: account, name: :invalid})
    end
  end

  describe "verify_customer/1" do
    setup [:generate_api_key]

    test "with valid token", %{api_key: %{api_key: api_key, account_id: account_id}} do
      {:ok, %{account_id: ^account_id}} = ApiKeys.verify_customer(api_key)
    end

    test "with invalid token", %{api_key: %{account_id: not_existing_uuid}} do
      {:error, :invalid} = ApiKeys.verify_customer(not_existing_uuid)
    end
  end

  describe "update/2" do
    test "with valid params", %{
      api_key: %{id: api_key_id},
      new_name: new_name,
      new_encrypted_api_key: new_encrypted_api_key
    } do
      {:ok, %ApiKey{id: ^api_key_id, name: ^new_name, encrypted_api_key: ^new_encrypted_api_key}} =
        ApiKeys.update(api_key_id, %{name: new_name, encrypted_api_key: new_encrypted_api_key})
    end

    test "with valid name", %{
      api_key: %{id: api_key_id, encrypted_api_key: encrypted_api_key},
      new_name: new_name
    } do
      {:ok, %ApiKey{id: ^api_key_id, name: ^new_name, encrypted_api_key: ^encrypted_api_key}} =
        ApiKeys.update(api_key_id, %{name: new_name})
    end

    test "with valid encrypted_api_key", %{
      api_key: %{id: api_key_id, name: name},
      new_encrypted_api_key: new_encrypted_api_key
    } do
      {:ok, %ApiKey{id: ^api_key_id, name: ^name, encrypted_api_key: ^new_encrypted_api_key}} =
        ApiKeys.update(api_key_id, %{encrypted_api_key: new_encrypted_api_key})
    end
  end

  describe "retrieve_by_id/1" do
    test "with valid id", %{
      api_key: %{id: api_key_id, name: name, encrypted_api_key: encrypted_api_key}
    } do
      {:ok, %ApiKey{id: ^api_key_id, name: ^name, encrypted_api_key: ^encrypted_api_key}} =
        ApiKeys.retrieve_by_id(api_key_id)
    end
  end

  defp generate_api_key(%{account: account, name: name}) do
    {:ok, api_key} = ApiKeys.create(%{account: account, name: name})

    %{api_key: api_key}
  end
end
