defmodule TalbotClient.Commands do
  @moduledoc """
  Redirect message to the desired handler.
  """

  require Logger
  alias Nadia.Model.Update
  alias TalbotClient.{Commands, Pipeline}

  @spec match_message(Update.t()) :: :ok
  def match_message(update) do
    update
    |> Pipeline.start()
    |> Pipeline.on_valid(&delegate_message/1)
    |> Pipeline.send_message()
    |> check_result()
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp delegate_message(pipeline) do
    case pipeline.command do
      "help" -> Commands.Help.handle_message(pipeline)
      "start" -> Commands.Start.handle_message(pipeline)
      "web" -> Commands.Web.handle_message(pipeline)
      "locale" -> Commands.Locale.handle_message(pipeline)
      "n" -> Commands.New.handle_message(pipeline)
      "new" -> Commands.New.handle_message(pipeline)
      "e" -> Commands.Edit.handle_message(pipeline)
      "edit" -> Commands.Edit.handle_message(pipeline)
      "s" -> Commands.Show.handle_message(pipeline)
      "show" -> Commands.Show.handle_message(pipeline)
      "l" -> Commands.List.handle_message(pipeline)
      "list" -> Commands.List.handle_message(pipeline)
      "la" -> Commands.List.handle_message(pipeline, true)
      "listwithabbr" -> Commands.List.handle_message(pipeline, true)
      "d" -> Commands.Delete.handle_message(pipeline)
      "delete" -> Commands.Delete.handle_message(pipeline)
      "se" -> Commands.Select.handle_message(pipeline)
      "select" -> Commands.Select.handle_message(pipeline)
      "sr" -> Commands.SelectRandom.handle_message(pipeline)
      "selectrandom" -> Commands.SelectRandom.handle_message(pipeline)
      "ar" -> Commands.Archive.handle_message(pipeline)
      "archive" -> Commands.Archive.handle_message(pipeline)
      _command -> Pipeline.set_error(pipeline, :unknown_command)
    end
  end

  defp check_result(pipeline) do
    if pipeline.valid? do
      :ok
    else
      Logger.warn("Command '#{pipeline.command}' failed: #{pipeline.error}")
      {:error, pipeline.error}
    end
  end
end
