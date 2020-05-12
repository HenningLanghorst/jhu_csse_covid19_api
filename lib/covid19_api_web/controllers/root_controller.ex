defmodule Covid19ApiWeb.RootController do
  use Covid19ApiWeb, :controller

  def index(conn, _), do: conn |> text("Hello world!")
end
