defmodule TalbotWeb.ChatGroupLiveTest do
  use TalbotWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Talbot.Telegram

  @create_attrs %{id: 42, title: "some title"}
  @update_attrs %{id: 43, title: "some updated title"}
  @invalid_attrs %{id: nil, title: nil}

  defp fixture(:chat_group) do
    {:ok, chat_group} = Telegram.create_chat_group(@create_attrs)
    chat_group
  end

  defp create_chat_group(_) do
    chat_group = fixture(:chat_group)
    %{chat_group: chat_group}
  end

  describe "Index" do
    setup [:create_chat_group]

    test "lists all chat_groups", %{conn: conn, chat_group: chat_group} do
      {:ok, _index_live, html} = live(conn, Routes.chat_group_index_path(conn, :index))

      assert html =~ "Listing Chat groups"
      assert html =~ chat_group.title
    end

    test "saves new chat_group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.chat_group_index_path(conn, :index))

      assert index_live |> element("a", "New Chat group") |> render_click() =~
               "New Chat group"

      assert_patch(index_live, Routes.chat_group_index_path(conn, :new))

      assert index_live
             |> form("#chat_group-form", chat_group: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chat_group-form", chat_group: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_group_index_path(conn, :index))

      assert html =~ "Chat group created successfully"
      assert html =~ "some title"
    end

    test "updates chat_group in listing", %{conn: conn, chat_group: chat_group} do
      {:ok, index_live, _html} = live(conn, Routes.chat_group_index_path(conn, :index))

      assert index_live |> element("#chat_group-#{chat_group.id} a", "Edit") |> render_click() =~
               "Edit Chat group"

      assert_patch(index_live, Routes.chat_group_index_path(conn, :edit, chat_group))

      assert index_live
             |> form("#chat_group-form", chat_group: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#chat_group-form", chat_group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_group_index_path(conn, :index))

      assert html =~ "Chat group updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes chat_group in listing", %{conn: conn, chat_group: chat_group} do
      {:ok, index_live, _html} = live(conn, Routes.chat_group_index_path(conn, :index))

      assert index_live |> element("#chat_group-#{chat_group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chat_group-#{chat_group.id}")
    end
  end

  describe "Show" do
    setup [:create_chat_group]

    test "displays chat_group", %{conn: conn, chat_group: chat_group} do
      {:ok, _show_live, html} = live(conn, Routes.chat_group_show_path(conn, :show, chat_group))

      assert html =~ "Show Chat group"
      assert html =~ chat_group.title
    end

    test "updates chat_group within modal", %{conn: conn, chat_group: chat_group} do
      {:ok, show_live, _html} = live(conn, Routes.chat_group_show_path(conn, :show, chat_group))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chat group"

      assert_patch(show_live, Routes.chat_group_show_path(conn, :edit, chat_group))

      assert show_live
             |> form("#chat_group-form", chat_group: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#chat_group-form", chat_group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.chat_group_show_path(conn, :show, chat_group))

      assert html =~ "Chat group updated successfully"
      assert html =~ "some updated title"
    end
  end
end
