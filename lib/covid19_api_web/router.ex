defmodule Covid19ApiWeb.Router do
  use Covid19ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Covid19ApiWeb do
    pipe_through :api

    get "/", Convid19Controller, :index
  end
end
