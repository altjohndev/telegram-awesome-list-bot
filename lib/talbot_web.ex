defmodule TalbotWeb do
  @moduledoc """
  Web features.
  """

  @spec controller :: {:__block__, list(), list()}
  def controller do
    quote do
      use Phoenix.Controller, namespace: TalbotWeb

      import Plug.Conn
      import Talbot.Gettext
      alias TalbotWeb.Router.Helpers, as: Routes
    end
  end

  @spec view :: {:__block__, list(), list()}
  def view do
    quote do
      use Phoenix.View,
        root: "lib/talbot_web/templates",
        namespace: TalbotWeb

      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      unquote(view_helpers())
    end
  end

  @spec live_view :: {:__block__, list(), list()}
  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {TalbotWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  @spec live_component :: {:__block__, list(), list()}
  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  @spec router :: {:__block__, list(), list()}
  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  @spec channel :: {:__block__, list(), list()}
  def channel do
    quote do
      use Phoenix.Channel
      import Talbot.Gettext
    end
  end

  defp view_helpers do
    quote do
      use Phoenix.HTML

      import Phoenix.LiveView.Helpers
      import TalbotWeb.LiveHelpers

      import Phoenix.View

      import TalbotWeb.ErrorHelpers
      import Talbot.Gettext
      alias TalbotWeb.Router.Helpers, as: Routes
    end
  end

  @spec __using__(atom()) :: any()
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
