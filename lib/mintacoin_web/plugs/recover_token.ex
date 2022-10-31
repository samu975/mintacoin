defmodule MintacoinWeb.Plugs.RecoverToken do
   @moduledoc """
  Plug to recover customer token to the conn
  """
  @behaviour Plug

  import Plug.Conn, only: [assign: 3]

end
