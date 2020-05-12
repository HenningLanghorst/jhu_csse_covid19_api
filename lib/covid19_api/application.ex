defmodule Covid19Api.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      Covid19ApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Covid19Api.PubSub},
      # Start the Endpoint (http/https)
      Covid19ApiWeb.Endpoint
      # Start a worker by calling: Covid19Api.Worker.start_link(arg)
      # {Covid19Api.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Covid19Api.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Covid19ApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
