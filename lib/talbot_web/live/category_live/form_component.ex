defmodule TalbotWeb.CategoryLive.FormComponent do
  @moduledoc """
  Live component of a `Talbot.Listings.Category` form.
  """

  use TalbotWeb, :live_component
  import Talbot.Gettext, only: [gettext: 1, dgettext: 2]
  alias Phoenix.LiveView.Socket
  alias Talbot.Listings.Categories

  @gettext_domain "web"

  @impl Phoenix.LiveComponent
  @spec update(Socket.assigns(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{category: category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, Categories.change(category))}
  end

  @impl Phoenix.LiveComponent
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Categories.change(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  defp save_category(socket, :edit_category, category_params) do
    case Categories.update(socket.assigns.category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Category updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_category(socket, :new_category, category_params) do
    case Categories.create(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Category created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
