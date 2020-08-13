defmodule TalbotWeb.ChatLive.FormComponent do
  @moduledoc """
  Live component of a `Talbot.Telegram.Chat` form.
  """

  use TalbotWeb, :live_component
  import Talbot.Gettext, only: [gettext: 1, dgettext: 2]
  alias Phoenix.LiveView.Socket
  alias Talbot.Telegram.Chats

  @gettext_domain "web"

  @impl Phoenix.LiveComponent
  @spec update(Socket.assigns(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{chat: chat} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Chats.change(chat))}
  end

  @impl Phoenix.LiveComponent
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"chat" => chat_params}, socket) do
    changeset =
      socket.assigns.chat
      |> Chats.change(chat_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"chat" => chat_params}, socket) do
    save_chat(socket, socket.assigns.action, chat_params)
  end

  defp save_chat(socket, :edit_chat, chat_params) do
    case Chats.update(socket.assigns.chat, chat_params) do
      {:ok, _chat} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Chat updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
