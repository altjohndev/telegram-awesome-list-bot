defmodule TalbotWeb.ChatUserLiveTest do
  use TalbotWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Talbot.Telegram

  @create_attrs %{first_name: "some first_name", id: 42, last_name: "some last_name", username: "some username"}
  @update_attrs %{
    first_name: "some updated first_name",
    id: 43,
    last_name: "some updated last_name",
    username: "some updated username"
  }
  @invalid_attrs %{first_name: nil, id: nil, last_name: nil, username: nil}

  defp fixture(:chat_user) do
    {:ok, chat_user} = Telegram.create_chat_user(@create_attrs)
    chat_user
  end

  defp create_chat_user(_) do
    chat_user = fixture(:chat_user)
    %{chat_user: chat_user}
  end

  describe "Index" do
    setup [:create_chat_user]

    test "lists all chat_users", %{conn: conn, chat_user: chat_user} do
      {:ok, _index_live, html} = live(conn, Routes.chat_user_index_path(conn, :index))

      assert html =~ "Listing Chat users"
      assert html =~ chat_user.first_name
    end

    test "saves new chat_user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.chat_user_index_path(conn, :index))

      assert index_live |> element("a", "New Chat user") |> render_click() =~
               "New Chat user"

      assert_patch(index_live, Routes.chat_user_index_path(conn, :new))

      assert index_live
             |> form("#chat_user-form", chat_user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chat_user-form", chat_user: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_user_index_path(conn, :index))

      assert html =~ "Chat user created successfully"
      assert html =~ "some first_name"
    end

    test "updates chat_user in listing", %{conn: conn, chat_user: chat_user} do
      {:ok, index_live, _html} = live(conn, Routes.chat_user_index_path(conn, :index))

      assert index_live |> element("#chat_user-#{chat_user.id} a", "Edit") |> render_click() =~
               "Edit Chat user"

      assert_patch(index_live, Routes.chat_user_index_path(conn, :edit, chat_user))

      assert index_live
             |> form("#chat_user-form", chat_user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chat_user-form", chat_user: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_user_index_path(conn, :index))

      assert html =~ "Chat user updated successfully"
      assert html =~ "some updated first_name"
    end

    test "deletes chat_user in listing", %{conn: conn, chat_user: chat_user} do
      {:ok, index_live, _html} = live(conn, Routes.chat_user_index_path(conn, :index))

      assert index_live |> element("#chat_user-#{chat_user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chat_user-#{chat_user.id}")
    end
  end

  describe "Show" do
    setup [:create_chat_user]

    test "displays chat_user", %{conn: conn, chat_user: chat_user} do
      {:ok, _show_live, html} = live(conn, Routes.chat_user_show_path(conn, :show, chat_user))

      assert html =~ "Show Chat user"
      assert html =~ chat_user.first_name
    end

    test "updates chat_user within modal", %{conn: conn, chat_user: chat_user} do
      {:ok, show_live, _html} = live(conn, Routes.chat_user_show_path(conn, :show, chat_user))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chat user"

      assert_patch(show_live, Routes.chat_user_show_path(conn, :edit, chat_user))

      assert show_live
             |> form("#chat_user-form", chat_user: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#chat_user-form", chat_user: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_user_show_path(conn, :show, chat_user))

      assert html =~ "Chat user updated successfully"
      assert html =~ "some updated first_name"
    end
  end
end
