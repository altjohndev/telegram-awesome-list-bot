defmodule TalbotClient.Commands.Locale do
  @moduledoc """
  Command to update the chat language.
  """

  use TalbotClient.Pipeline
  alias Talbot.Telegram.Chats

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{chat: chat, command_input: input} = pipeline) do
    if input != chat.locale do
      if input in known_locales() do
        case Chats.update(chat, %{locale: input}) do
          {:ok, chat} ->
            update_locale(input)

            pipeline
            |> struct(chat: chat)
            |> append_message(&build_message/1)

          {:error, error} ->
            set_changeset_error(pipeline, error, :failed_to_update_locale)
        end
      else
        set_error(pipeline, :invalid_locale_input)
      end
    else
      set_error(pipeline, :locale_already_set)
    end
  end

  defp build_message(_pipeline) do
    dgettext(@gettext_domain, "私はロボット...! Just kidding! I successfully updated the language.")
  end
end
