defmodule MultiPageForm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MultiPageForm.Repo,
      # Start the Telemetry supervisor
      MultiPageFormWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MultiPageForm.PubSub},
      # Start the Endpoint (http/https)
      MultiPageFormWeb.Endpoint
      # Start a worker by calling: MultiPageForm.Worker.start_link(arg)
      # {MultiPageForm.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MultiPageForm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MultiPageFormWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
