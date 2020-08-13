defmodule TalbotWeb.PageLive do
  @moduledoc """
  Live controller for Page.
  """

  use TalbotWeb, :live_view
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  @spec mount(map(), map(), Socket.t()) :: {:ok, Socket.t()}
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
