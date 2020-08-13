defmodule TalbotWeb.ChatLive.Show do
  @moduledoc """
  Live controller to show `Talbot.Telegram.Chat` data.
  """

  use TalbotWeb, :live_view
  import Talbot.Gettext, only: [gettext: 1, dgettext: 2, dgettext: 3, known_locales: 0, update_locale: 1]
  alias Phoenix.LiveView.Socket
  alias Talbot.{Listings, Telegram}

  @gettext_domain "web"

  @impl Phoenix.LiveView
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  @spec handle_params(map(), String.t(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_params(params, _url, socket) do
    socket = assign(socket, :locales, known_locales())

    with {:ok, {socket, chat_id}} <- handle_chat(socket, params),
         {:ok, socket} <- handle_action(socket, chat_id, socket.assigns.live_action, params) do
      {:noreply, socket}
    else
      {:error, {socket, reason}} -> {:noreply, handle_error(socket, reason)}
    end
  end

  # Chat

  defp handle_chat(socket, %{"chat_id" => id, "passcode" => passcode}) do
    %{passcode: chat_passcode, passcode_expires_at: expiration_date, locale: locale} = chat = Telegram.Chats.get!(id)

    if chat_passcode == passcode do
      if NaiveDateTime.compare(NaiveDateTime.utc_now(), expiration_date) != :gt do
        update_locale(locale)

        socket =
          socket
          |> assign(:chat_id, id)
          |> assign(:categories, Listings.Categories.list_from_chat(id, [:sub_categories, items: [:sub_category]]))
          |> assign(:passcode, passcode)

        if socket.assigns.live_action == :edit_chat do
          socket =
            socket
            |> assign(:page_title, dgettext(@gettext_domain, "Update chat"))
            |> assign(:chat, chat)

          {:ok, {socket, id}}
        else
          {:ok, {socket, id}}
        end
      else
        {:error, {socket, :passcode_expired}}
      end
    else
      {:error, {socket, :invalid_passcode}}
    end
  rescue
    _error -> {:error, {socket, :chat_not_found}}
  end

  # Item

  defp handle_action(socket, chat_id, :new_item, %{"category_id" => category_id}) do
    %{name: name} = Listings.Categories.get_from_chat!(chat_id, category_id)

    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "New item from %{category}", category: name))
     |> assign(:category_id, category_id)
     |> assign(:sub_categories, Listings.SubCategories.list_from_category(category_id))
     |> assign(:item, %Listings.Item{})}
  rescue
    _error -> {:error, {socket, :category_not_found}}
  end

  defp handle_action(socket, chat_id, :edit_item, %{"category_id" => category_id, "item_id" => id}) do
    %{name: name} = Listings.Categories.get_from_chat!(chat_id, category_id)

    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "Update item from %{category}", category: name))
     |> assign(:category_id, category_id)
     |> assign(:sub_categories, Listings.SubCategories.list_from_category(category_id))
     |> assign(:item, Listings.Items.get_from_category!(category_id, id))}
  rescue
    _error -> {:error, {socket, :item_not_found}}
  end

  # Category

  defp handle_action(socket, _chat_id, :new_category, _params) do
    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "New category"))
     |> assign(:category, %Listings.Category{})}
  end

  defp handle_action(socket, chat_id, :edit_category, %{"category_id" => id}) do
    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "Update category"))
     |> assign(:category, Listings.Categories.get_from_chat!(chat_id, id))}
  rescue
    _error -> {:error, {socket, :category_not_found}}
  end

  # SubCategory

  defp handle_action(socket, chat_id, :new_sub_category, %{"category_id" => category_id}) do
    %{name: name} = Listings.Categories.get_from_chat!(chat_id, category_id)

    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "New sub-category from %{category}", category: name))
     |> assign(:category_id, category_id)
     |> assign(:sub_category, %Listings.SubCategory{})}
  rescue
    _error -> {:error, {socket, :sub_category_not_found}}
  end

  defp handle_action(socket, chat_id, :edit_sub_category, %{"category_id" => category_id, "sub_category_id" => id}) do
    %{name: name} = Listings.Categories.get_from_chat!(chat_id, category_id)

    {:ok,
     socket
     |> assign(:page_title, dgettext(@gettext_domain, "Update sub-category from %{category}", category: name))
     |> assign(:category_id, category_id)
     |> assign(:sub_category, Listings.SubCategories.get_from_category!(category_id, id))}
  rescue
    _error -> {:error, {socket, :sub_category_not_found}}
  end

  # Selects

  defp handle_action(socket, chat_id, :select_from_category, %{"category_id" => id}) do
    items =
      chat_id
      |> Listings.Categories.get_from_chat!(id, [:items])
      |> Map.get(:items, [])
      |> Enum.filter(&(&1.selected == false and &1.archived == false))

    if Enum.any?(items) do
      {:ok, %{name: name}} =
        items
        |> Enum.random()
        |> Listings.Items.update(%{selected: true})

      {:ok,
       socket
       |> put_flash(:info, dgettext(@gettext_domain, "Item %{item} selected!", item: name))
       |> assign(:categories, Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]]))}
    else
      {:error, {socket, :select_empty}}
    end
  rescue
    _error -> {:error, {socket, :category_not_found}}
  end

  defp handle_action(socket, chat_id, :select_from_sub_category, %{"sub_category_id" => id}) do
    items =
      chat_id
      |> Listings.SubCategories.get_from_chat!(id, [:items])
      |> Map.get(:items, [])
      |> Enum.filter(&(&1.selected == false and &1.archived == false))

    if Enum.any?(items) do
      {:ok, %{name: name}} =
        items
        |> Enum.random()
        |> Listings.Items.update(%{selected: true})

      {:ok,
       socket
       |> put_flash(:info, dgettext(@gettext_domain, "Item %{item} selected!", item: name))
       |> assign(:categories, Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]]))}
    else
      {:error, {socket, :select_empty}}
    end
  rescue
    _error -> {:error, {socket, :sub_category_not_found}}
  end

  # General

  defp handle_action(socket, _chat_id, _action, _params) do
    {:ok, socket}
  end

  # Delete

  @impl Phoenix.LiveView
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("delete_category", %{"id" => id}, socket) do
    chat_id = socket.assigns.chat_id

    %{name: name} = category = Listings.Categories.get_from_chat!(chat_id, id)
    {:ok, _category} = Listings.Categories.delete(category)

    {:noreply,
     socket
     |> put_flash(:info, dgettext(@gettext_domain, "Category %{category} removed", category: name))
     |> assign(:categories, Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]]))}
  rescue
    _error -> handle_error(socket, :failed_to_remove_category)
  end

  def handle_event("delete_sub_category", %{"id" => id}, socket) do
    chat_id = socket.assigns.chat_id

    %{name: name} = sub_category = Listings.SubCategories.get_from_chat!(chat_id, id)
    {:ok, _sub_category} = Listings.SubCategories.delete(sub_category)

    {:noreply,
     socket
     |> put_flash(:info, dgettext(@gettext_domain, "Sub-category %{sub_category} removed", sub_category: name))
     |> assign(:categories, Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]]))}
  rescue
    _error -> handle_error(socket, :failed_to_remove_sub_category)
  end

  def handle_event("delete_item", %{"id" => id}, socket) do
    chat_id = socket.assigns.chat_id

    %{name: name} = item = Listings.Items.get_from_chat!(chat_id, id)
    {:ok, _item} = Listings.Items.delete(item)

    {:noreply,
     socket
     |> put_flash(:info, dgettext(@gettext_domain, "Item %{item} removed", item: name))
     |> assign(:categories, Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]]))}
  rescue
    _error -> handle_error(socket, :failed_to_remove_item)
  end

  # Toggle

  def handle_event("toggle_select", %{"id" => id}, socket) do
    chat_id = socket.assigns.chat_id

    {:ok, _item} =
      chat_id
      |> Listings.Items.get_from_chat!(id)
      |> Listings.Items.toggle_select()

    {
      :noreply,
      assign(
        socket,
        :categories,
        Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]])
      )
    }
  rescue
    _error -> handle_error(socket, :failed_to_select_item)
  end

  def handle_event("toggle_archive", %{"id" => id}, socket) do
    chat_id = socket.assigns.chat_id

    {:ok, _item} =
      chat_id
      |> Listings.Items.get_from_chat!(id)
      |> Listings.Items.toggle_archive()

    {
      :noreply,
      assign(
        socket,
        :categories,
        Listings.Categories.list_from_chat(chat_id, [:sub_categories, items: [:sub_category]])
      )
    }
  rescue
    _error -> handle_error(socket, :failed_to_archive_item)
  end

  # Errors

  defp handle_error(socket, :passcode_expired) do
    message =
      raw(
        dgettext(
          @gettext_domain,
          "Your link expired. Please request a new link to the bot with <code>/web</code> command"
        )
      )

    socket
    |> put_flash(:error, message)
    |> redirect(to: "/")
  end

  defp handle_error(socket, :invalid_passcode) do
    handle_error(socket, :passcode_expired)
  end

  defp handle_error(socket, :chat_not_found) do
    handle_error(socket, :passcode_expired)
  end

  defp handle_error(socket, :category_not_found) do
    message = dgettext(@gettext_domain, "Category not found")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :sub_category_not_found) do
    message = dgettext(@gettext_domain, "Sub-category not found")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :item_not_found) do
    message = dgettext(@gettext_domain, "Item not found")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :select_empty) do
    message = dgettext(@gettext_domain, "There are no items available to be selected")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :failed_to_archive_item) do
    message = dgettext(@gettext_domain, "Failed to archive item")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :failed_to_remove_category) do
    message = dgettext(@gettext_domain, "Failed to remove category")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :failed_to_remove_sub_category) do
    message = dgettext(@gettext_domain, "Failed to remove sub-category")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :failed_to_remove_item) do
    message = dgettext(@gettext_domain, "Failed to remove item")

    put_flash(socket, :error, message)
  end

  defp handle_error(socket, :failed_to_select_item) do
    message = dgettext(@gettext_domain, "Failed to select item")

    put_flash(socket, :error, message)
  end
end
