defmodule DemoApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DemoAppWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:demo_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: DemoApp.PubSub},
      # Start a worker by calling: DemoApp.Worker.start_link(arg)
      # {DemoApp.Worker, arg},
      # Start to serve requests, typically the last entry
      DemoAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DemoApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DemoAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
