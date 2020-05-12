defmodule Covid19ApiWeb.Router do
  use Covid19ApiWeb, :router

  alias Covid19ApiWeb.RootController

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api
    get "/", RootController, :index
  end

  scope "/covid-19/api", Covid19ApiWeb do
    pipe_through :api

    scope "/v1" do
      get "/time-series/countries", Covid19Controller, :countries
      get "/time-series/countries/:country/provinces", Covid19Controller, :provinces
      get "/time-series/countries/:country", Covid19Controller, :time_series
      get "/time-series/countries/:country/:time_series", Covid19Controller, :time_series
      get "/time-series/countries/:country/provinces/:province", Covid19Controller, :time_series

      get "/time-series/countries/:country/provinces/:province/:time_series",
          Covid19Controller,
          :time_series
    end
  end
end
