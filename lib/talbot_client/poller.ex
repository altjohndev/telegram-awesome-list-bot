defmodule TalbotClient.Poller do
  @moduledoc """
  GenServer to manage the incoming of Telegram chat messages.

  Original source: https://github.com/lubien/elixir-telegram-bot-boilerplate/
  """

  use GenServer
  require Logger

  # Server

  @spec start_link(any()) :: {:ok, pid} | :ignore | {:error, any()}
  def start_link(_args) do
    Logger.log(:info, "Started poller")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, 0}
  def init(:ok) do
    update()
    {:ok, 0}
  end

  def handle_cast(:update, offset) do
    new_offset = process_messages(Nadia.get_updates(offset: offset))

    {:noreply, new_offset + 1, 100}
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  # Client

  @spec update :: :ok
  def update do
    GenServer.cast(__MODULE__, :update)
  end

  # Helpers

  defp process_messages({:ok, []}), do: -1

  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{update_id: id} = message ->
      message
      |> process_message

      id
    end)
    |> List.last()
  end

  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}) do
    Logger.log(:error, reason)

    -1
  end

  defp process_message(message) do
    TalbotClient.Matcher.match(message)
  rescue
    err in MatchError -> Logger.warn("Errored with #{err} at #{Jason.encode!(message)}")
  end
end
