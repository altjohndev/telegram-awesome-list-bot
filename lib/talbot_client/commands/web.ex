defmodule TalbotClient.Commands.Web do
  @moduledoc """
  Command to reply the web link to the chat data.
  """

  @gettext_domain "client"

  use TalbotClient.Pipeline
  alias Talbot.Telegram.Chats
  alias TalbotWeb.{Endpoint, Router}

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(pipeline) do
    pipeline
    |> update_chat_passcode()
    |> append_message(&build_message/1)
  end

  defp update_chat_passcode(%{chat: chat} = pipeline) do
    case Chats.update_passcode(chat) do
      {:ok, chat} -> struct(pipeline, chat: chat)
      {:error, _error} -> set_error(pipeline, :failed_to_update_chat_passcode)
    end
  end

  defp build_message(%{chat: chat}) do
    dgettext(
      @gettext_domain,
      """
      The link below will expire in 1 hour:

      <a href="%{link}">%{link}</a>
      """,
      link: chat_link(chat.id, chat.passcode)
    )
  end

  defp chat_link(chat_id, passcode) do
    String.replace(Endpoint.url(), ":80", "") <>
      Router.Helpers.chat_show_path(TalbotWeb.Endpoint, :show, chat_id, passcode)
  end
end
