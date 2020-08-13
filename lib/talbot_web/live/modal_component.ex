defmodule TalbotWeb.ModalComponent do
  @moduledoc """
  Component to render a modal.
  """

  use TalbotWeb, :live_component
  alias Phoenix.LiveView

  @impl Phoenix.LiveComponent
  @spec render(any()) :: LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content">
        <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  @spec handle_event(String.t(), map(), LiveView.Socket.t()) :: {:noreply, LiveView.Socket.t()}
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
