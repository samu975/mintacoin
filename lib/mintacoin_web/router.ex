defmodule MintacoinWeb.Router do
  use MintacoinWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug MintacoinWeb.Plugs.SetBlockchainNetwork
    plug MintacoinWeb.Plugs.VerifyApiToken
  end

  pipeline :verify_customer do
    plug :accepts, ["json"]
    plug MintacoinWeb.Plugs.VerifyCustomer
  end

  scope "/", MintacoinWeb do
    pipe_through :api

    resources "/accounts", AccountsController, param: "address", except: [:index, :show]
    post "/accounts/:address/recover", AccountsController, :recover

    resources "/assets", AssetsController, except: [:index]
    get "/assets/:id/issuer", AssetsController, :show_issuer
    get "/assets/:id/accounts", AssetsController, :show_accounts
  end

  scope "/", MintacoinWeb do
    pipe_through :verify_customer

    get "/customers/:address/recover", CustomerController, :verify_customer
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: MintacoinWeb.Telemetry
    end
  end
end
