defmodule TalbotWeb.ItemLive.FormComponent do
  @moduledoc """
  Live component of a `Talbot.Listings.Item` form.
  """

  use TalbotWeb, :live_component
  import Talbot.Gettext, only: [gettext: 1, dgettext: 2]
  alias Phoenix.LiveView.Socket
  alias Talbot.Listings.Items

  @gettext_domain "web"

  @impl Phoenix.LiveComponent
  @spec update(Socket.assigns(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{item: item} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Items.change(item))}
  end

  @impl Phoenix.LiveComponent
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Items.change(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.action, item_params)
  end

  defp save_item(socket, :edit_item, item_params) do
    case Items.update(socket.assigns.item, item_params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Item updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_item(socket, :new_item, item_params) do
    case Items.create(item_params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Item created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
