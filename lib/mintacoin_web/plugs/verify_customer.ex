defmodule MintacoinWeb.Plugs.VerifyCustomer do
  @moduledoc """
  Plug to recover customer token to the conn
  """
  @behaviour Plug

  import Plug.Conn
  import Jason

  @impl true
  def init(default), do: default

  @impl true
  def call(conn, _default) do
    conn
    |> get_adress_and_signature()
    |> verify_keypair()
    |> verify_customer()
  end

  defp get_adress_and_signature(conn) do
    signature = with {:ok, body, _conn} <- read_body(conn),
     {:ok, %{"signature" => body_signature}} <- decode(body) do
        body_signature
     end

    %Plug.Conn{params: %{"address" => address}} = conn

     {address, signature}
  end

  defp verify_keypair({address, signature}) do
    IO.inspect(address, label: "addres:")
    IO.inspect(signature, label: "signature:")
  end

  defp verify_customer(account) do
  end
end
