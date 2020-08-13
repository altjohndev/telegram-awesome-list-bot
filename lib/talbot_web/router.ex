defmodule TalbotWeb.Router do
  @moduledoc """
  Phoenix web routing.
  """

  use TalbotWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TalbotWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TalbotWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live_dashboard "/dashboard", metrics: TalbotWeb.Telemetry
  end

  scope "/:chat_id/:passcode/" do
    pipe_through :browser

    live "/", TalbotWeb.ChatLive.Show, :show
    live "/edit", TalbotWeb.ChatLive.Show, :edit_chat

    live "/categories/new", TalbotWeb.ChatLive.Show, :new_category
    live "/categories/:category_id/edit", TalbotWeb.ChatLive.Show, :edit_category

    live "/categories/:category_id/sub-categories/new", TalbotWeb.ChatLive.Show, :new_sub_category
    live "/categories/:category_id/sub-categories/:sub_category_id/edit", TalbotWeb.ChatLive.Show, :edit_sub_category

    live "/categories/:category_id/sub-categories/:sub_category_id/items/select",
         TalbotWeb.ChatLive.Show,
         :select_from_sub_category

    live "/categories/:category_id/items/new", TalbotWeb.ChatLive.Show, :new_item
    live "/categories/:category_id/items/select", TalbotWeb.ChatLive.Show, :select_from_category
    live "/categories/:category_id/items/:item_id/edit", TalbotWeb.ChatLive.Show, :edit_item
  end
end
