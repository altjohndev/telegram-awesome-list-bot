defmodule Talbot.Application do
  @moduledoc false

  use Application

  @spec start(any(), any()) :: {:ok, pid} | {:error, any()}
  def start(_type, _args) do
    children = [
      Talbot.Repo,
      TalbotWeb.Telemetry,
      {Phoenix.PubSub, name: Talbot.PubSub},
      TalbotWeb.Endpoint,
      TalbotClient.Poller,
      TalbotClient.Matcher
    ]

    opts = [strategy: :one_for_one, name: Talbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec config_change(any(), any(), any()) :: :ok
  def config_change(changed, _new, removed) do
    TalbotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
