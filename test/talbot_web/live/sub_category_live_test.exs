defmodule TalbotWeb.SubCategoryLiveTest do
  use TalbotWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Talbot.Listings

  @create_attrs %{
    abbr: "some abbr",
    description: "some description",
    id: "7488a646-e31f-11e4-aace-600308960662",
    name: "some name"
  }
  @update_attrs %{
    abbr: "some updated abbr",
    description: "some updated description",
    id: "7488a646-e31f-11e4-aace-600308960668",
    name: "some updated name"
  }
  @invalid_attrs %{abbr: nil, description: nil, id: nil, name: nil}

  defp fixture(:sub_category) do
    {:ok, sub_category} = Listings.create_sub_category(@create_attrs)
    sub_category
  end

  defp create_sub_category(_) do
    sub_category = fixture(:sub_category)
    %{sub_category: sub_category}
  end

  describe "Index" do
    setup [:create_sub_category]

    test "lists all sub_categories", %{conn: conn, sub_category: sub_category} do
      {:ok, _index_live, html} = live(conn, Routes.sub_category_index_path(conn, :index))

      assert html =~ "Listing Sub categories"
      assert html =~ sub_category.abbr
    end

    test "saves new sub_category", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.sub_category_index_path(conn, :index))

      assert index_live |> element("a", "New Sub category") |> render_click() =~
               "New Sub category"

      assert_patch(index_live, Routes.sub_category_index_path(conn, :new))

      assert index_live
             |> form("#sub_category-form", sub_category: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sub_category-form", sub_category: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sub_category_index_path(conn, :index))

      assert html =~ "Sub category created successfully"
      assert html =~ "some abbr"
    end

    test "updates sub_category in listing", %{conn: conn, sub_category: sub_category} do
      {:ok, index_live, _html} = live(conn, Routes.sub_category_index_path(conn, :index))

      assert index_live |> element("#sub_category-#{sub_category.id} a", "Edit") |> render_click() =~
               "Edit Sub category"

      assert_patch(index_live, Routes.sub_category_index_path(conn, :edit, sub_category))

      assert index_live
             |> form("#sub_category-form", sub_category: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#sub_category-form", sub_category: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sub_category_index_path(conn, :index))

      assert html =~ "Sub category updated successfully"
      assert html =~ "some updated abbr"
    end

    test "deletes sub_category in listing", %{conn: conn, sub_category: sub_category} do
      {:ok, index_live, _html} = live(conn, Routes.sub_category_index_path(conn, :index))

      assert index_live |> element("#sub_category-#{sub_category.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#sub_category-#{sub_category.id}")
    end
  end

  describe "Show" do
    setup [:create_sub_category]

    test "displays sub_category", %{conn: conn, sub_category: sub_category} do
      {:ok, _show_live, html} = live(conn, Routes.sub_category_show_path(conn, :show, sub_category))

      assert html =~ "Show Sub category"
      assert html =~ sub_category.abbr
    end

    test "updates sub_category within modal", %{conn: conn, sub_category: sub_category} do
      {:ok, show_live, _html} = live(conn, Routes.sub_category_show_path(conn, :show, sub_category))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Sub category"

      assert_patch(show_live, Routes.sub_category_show_path(conn, :edit, sub_category))

      assert show_live
             |> form("#sub_category-form", sub_category: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#sub_category-form", sub_category: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.sub_category_show_path(conn, :show, sub_category))

      assert html =~ "Sub category updated successfully"
      assert html =~ "some updated abbr"
    end
  end
end
