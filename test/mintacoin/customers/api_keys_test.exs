defmodule Mintacoin.Customers.ApiKeysTest do
  @moduledoc """
  This module is used to group common tests for api key functions
  """

  use Mintacoin.DataCase, async: false

  import Mintacoin.Factory, only: [insert: 1]

  alias Ecto.{Adapters.SQL.Sandbox, Changeset}
  alias Mintacoin.{ApiKey, ApiKeys}

  setup do
    :ok = Sandbox.checkout(Mintacoin.Repo)

    account = insert(:account)
    api_key = insert(:api_key)

    %{
      account: account,
      api_key: api_key,
      name: "Customer",
      new_name: "Mintacoin",
      new_encrypted_api_key:
        "haooplkURD87vqXeq3svsKRxbokArcRhvoMnnbNbZqQRYmzrjI+Jn3gVmALejFwxgqRpbU9FmCDc5a6U3x4jW4mFqXr3I9mMoBeQS8HmLazHfDTytqhK8mCOdWkmnk7gDfbO167daVw2kK90E5jleYSY9Fcq3szryQPk5G5psP5SMkma9S9Gke+ail411PSbb/HUytuoI5hbqzyk8NbrXr3CV2w87mtcokIAznjx8Tk"
    }
  end

  describe "create/1" do
    test "with valid params", %{account: %{id: account_id} = account, name: name} do
      {:ok, %ApiKey{name: ^name, account_id: ^account_id}} =
        ApiKeys.create(%{account: account, name: name})
    end
  end

  describe "verify_customer/1" do
    test "with valid token", %{} do
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
end
