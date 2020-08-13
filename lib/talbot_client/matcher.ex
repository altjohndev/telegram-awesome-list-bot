defmodule TalbotClient.Matcher do
  @moduledoc """
  GenServer to handle Telegram chat messages.

  Original source: https://github.com/lubien/elixir-telegram-bot-boilerplate/
  """

  use GenServer
  alias TalbotClient.Commands

  # Server

  @spec start_link(any()) :: {:ok, pid} | :ignore | {:error, any()}
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, 0}
  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    Commands.match_message(message)

    {:noreply, state}
  end

  # Client

  @spec match(any()) :: :ok
  def match(message) do
    GenServer.cast(__MODULE__, message)
  end
end
