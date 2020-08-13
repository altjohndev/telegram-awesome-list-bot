defmodule TalbotWeb.LiveHelpers do
  @moduledoc """
  Utility for live controllers and templates.
  """

  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView

  @spec live_modal(LiveView.Socket.t(), any(), keyword()) :: LiveView.Component.t()
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, TalbotWeb.ModalComponent, modal_opts)
  end
end
