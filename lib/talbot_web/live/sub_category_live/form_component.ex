defmodule TalbotWeb.SubCategoryLive.FormComponent do
  @moduledoc """
  Live component of a `Talbot.Listings.SubCategory` form.
  """

  use TalbotWeb, :live_component
  import Talbot.Gettext, only: [gettext: 1, dgettext: 2]
  alias Phoenix.LiveView.Socket
  alias Talbot.Listings.SubCategories

  @gettext_domain "web"

  @impl Phoenix.LiveComponent
  @spec update(Socket.assigns(), Socket.t()) :: {:ok, Socket.t()}
  def update(%{sub_category: sub_category} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, SubCategories.change(sub_category))}
  end

  @impl Phoenix.LiveComponent
  @spec handle_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_event("validate", %{"sub_category" => sub_category_params}, socket) do
    changeset =
      socket.assigns.sub_category
      |> SubCategories.change(sub_category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"sub_category" => sub_category_params}, socket) do
    save_sub_category(socket, socket.assigns.action, sub_category_params)
  end

  defp save_sub_category(socket, :edit_sub_category, sub_category_params) do
    case SubCategories.update(socket.assigns.sub_category, sub_category_params) do
      {:ok, _sub_category} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Sub-category updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_sub_category(socket, :new_sub_category, sub_category_params) do
    case SubCategories.create(sub_category_params) do
      {:ok, _sub_category} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext(@gettext_domain, "Sub-category created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
