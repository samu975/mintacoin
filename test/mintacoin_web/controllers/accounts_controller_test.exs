defmodule MintacoinWeb.AccountsControllerTest do
  @moduledoc """
  This module is used to test account's endpoints
  """

  use MintacoinWeb.ConnCase
  use Oban.Testing, repo: Mintacoin.Repo

  import Mintacoin.Factory, only: [insert: 2]

  alias Mintacoin.{Accounts.StellarMock, Customer, Customers}

  setup %{conn: conn} do
    Application.put_env(:mintacoin, :crypto_impl, StellarMock)

    on_exit(fn ->
      Application.delete_env(:mintacoin, :crypto_impl)
    end)

    address = "GB3ZYW3WZWQU6CAEA6EQ4ALER456DPVBC6YLQRDKTTSNEVJOGFCECX5L"
    signature = "SB3RAKL2MRYZ53WJQAL5RJ42LPCMJTNDH4W7UWVRJA3GTEC66BC7VNUT"

    blockchain = insert(:blockchain, %{name: "stellar", network: "testnet"})
    account = insert(:account, %{address: address, signature: signature})

    {:ok, %Customer{api_key: api_token}} = Customers.create(%{account: account, name: "Customer"})

    conn_authenticated =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{api_token}")

    conn_invalid_token =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer INVALID_TOKEN")

    %{
      account: account,
      address: address,
      signature: signature,
      blockchain: blockchain,
      conn_authenticated: conn_authenticated,
      conn_unauthenticated: put_req_header(conn, "accept", "application/json"),
      conn_invalid_token: conn_invalid_token
    }
  end

  describe "create/2" do
    test "with valid params", %{conn_authenticated: conn, blockchain: %{name: blockchain_name}} do
      conn = post(conn, Routes.accounts_path(conn, :create), %{blockchain: blockchain_name})

      %{
        "data" => %{
          "address" => _address,
          "signature" => _signature,
          "seed_words" => _seed_words
        },
        "status" => 201
      } = json_response(conn, 201)
    end

    test "when blockchain is not valid", %{conn_authenticated: conn} do
      conn = post(conn, Routes.accounts_path(conn, :create), %{blockchain: "INVALID"})

      %{
        "code" => "blockchain_not_found",
        "detail" => "The introduced blockchain doesn't exist",
        "status" => 400
      } = json_response(conn, 400)
    end

    test "when blockchain is not present", %{conn_authenticated: conn} do
      conn = post(conn, Routes.accounts_path(conn, :create))

      json_response(conn, 400)
    end

    test "when authenticate token is invalid", %{
      conn_invalid_token: conn,
      blockchain: %{name: blockchain_name}
    } do
      conn = post(conn, Routes.accounts_path(conn, :create), %{blockchain: blockchain_name})

      %{
        "code" => 401,
        "detail" => "Invalid authorization Bearer token",
        "status" => "unauthorized"
      } = json_response(conn, 401)
    end

    test "when authenticate token is not submit", %{
      conn_unauthenticated: conn,
      blockchain: %{name: blockchain_name}
    } do
      conn = post(conn, Routes.accounts_path(conn, :create), %{blockchain: blockchain_name})

      %{
        "code" => 401,
        "detail" => "Missing authorization Bearer token",
        "status" => "unauthorized"
      } = json_response(conn, 401)
    end
  end

  describe "recover/2" do
    test "when params are valid", %{
      conn_authenticated: conn,
      address: address,
      account: %{signature: signature, seed_words: seed_words}
    } do
      conn = post(conn, Routes.accounts_path(conn, :recover, address), %{seed_words: seed_words})

      %{"data" => %{"signature" => ^signature}, "status" => 200} = json_response(conn, 200)
    end

    test "when address is invalid", %{
      conn_authenticated: conn,
      account: %{seed_words: seed_words}
    } do
      conn =
        post(conn, Routes.accounts_path(conn, :recover, "INVALID_ADDRESS"), %{
          seed_words: seed_words
        })

      %{"code" => "invalid_address", "detail" => "The address is invalid", "status" => 400} =
        json_response(conn, 400)
    end

    test "when seed_words is invalid", %{conn_authenticated: conn, address: address} do
      conn =
        post(conn, Routes.accounts_path(conn, :recover, address), %{
          seed_words: "INVALID_SEED_WORDS"
        })

      %{
        "code" => "invalid_seed_words",
        "detail" => "The seed words are invalid",
        "status" => 400
      } = json_response(conn, 400)
    end

    test "when seed_words are not present", %{conn_authenticated: conn, address: address} do
      conn = post(conn, Routes.accounts_path(conn, :recover, address))

      json_response(conn, 400)
    end

    test "when authorization Bearer token is invalid", %{
      conn_invalid_token: conn,
      address: address,
      account: %{seed_words: seed_words}
    } do
      conn = post(conn, Routes.accounts_path(conn, :recover, address), %{seed_words: seed_words})

      %{
        "code" => 401,
        "detail" => "Invalid authorization Bearer token",
        "status" => "unauthorized"
      } = json_response(conn, 401)
    end

    test "when authorization Bearer token is not submit", %{
      conn_unauthenticated: conn,
      address: address,
      account: %{seed_words: seed_words}
    } do
      conn = post(conn, Routes.accounts_path(conn, :recover, address), %{seed_words: seed_words})

      %{
        "code" => 401,
        "detail" => "Missing authorization Bearer token",
        "status" => "unauthorized"
      } = json_response(conn, 401)
    end
  end
end
