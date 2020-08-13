defmodule Talbot.ListingsTest do
  use Talbot.DataCase

  alias Talbot.Listings

  describe "categories" do
    alias Talbot.Listings.Category

    @valid_attrs %{
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

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Listings.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Listings.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Listings.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Listings.create_category(@valid_attrs)
      assert category.abbr == "some abbr"
      assert category.description == "some description"
      assert category.id == "7488a646-e31f-11e4-aace-600308960662"
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listings.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Listings.update_category(category, @update_attrs)
      assert category.abbr == "some updated abbr"
      assert category.description == "some updated description"
      assert category.id == "7488a646-e31f-11e4-aace-600308960668"
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.update_category(category, @invalid_attrs)
      assert category == Listings.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Listings.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Listings.change_category(category)
    end
  end

  describe "sub_categories" do
    alias Talbot.Listings.SubCategory

    @valid_attrs %{
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

    def sub_category_fixture(attrs \\ %{}) do
      {:ok, sub_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Listings.create_sub_category()

      sub_category
    end

    test "list_sub_categories/0 returns all sub_categories" do
      sub_category = sub_category_fixture()
      assert Listings.list_sub_categories() == [sub_category]
    end

    test "get_sub_category!/1 returns the sub_category with given id" do
      sub_category = sub_category_fixture()
      assert Listings.get_sub_category!(sub_category.id) == sub_category
    end

    test "create_sub_category/1 with valid data creates a sub_category" do
      assert {:ok, %SubCategory{} = sub_category} = Listings.create_sub_category(@valid_attrs)
      assert sub_category.abbr == "some abbr"
      assert sub_category.description == "some description"
      assert sub_category.id == "7488a646-e31f-11e4-aace-600308960662"
      assert sub_category.name == "some name"
    end

    test "create_sub_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listings.create_sub_category(@invalid_attrs)
    end

    test "update_sub_category/2 with valid data updates the sub_category" do
      sub_category = sub_category_fixture()
      assert {:ok, %SubCategory{} = sub_category} = Listings.update_sub_category(sub_category, @update_attrs)
      assert sub_category.abbr == "some updated abbr"
      assert sub_category.description == "some updated description"
      assert sub_category.id == "7488a646-e31f-11e4-aace-600308960668"
      assert sub_category.name == "some updated name"
    end

    test "update_sub_category/2 with invalid data returns error changeset" do
      sub_category = sub_category_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.update_sub_category(sub_category, @invalid_attrs)
      assert sub_category == Listings.get_sub_category!(sub_category.id)
    end

    test "delete_sub_category/1 deletes the sub_category" do
      sub_category = sub_category_fixture()
      assert {:ok, %SubCategory{}} = Listings.delete_sub_category(sub_category)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_sub_category!(sub_category.id) end
    end

    test "change_sub_category/1 returns a sub_category changeset" do
      sub_category = sub_category_fixture()
      assert %Ecto.Changeset{} = Listings.change_sub_category(sub_category)
    end
  end

  describe "items" do
    alias Talbot.Listings.Item

    @valid_attrs %{
      abbr: "some abbr",
      archived: true,
      description: "some description",
      id: "7488a646-e31f-11e4-aace-600308960662",
      name: "some name",
      reference: "some reference",
      selected: true
    }
    @update_attrs %{
      abbr: "some updated abbr",
      archived: false,
      description: "some updated description",
      id: "7488a646-e31f-11e4-aace-600308960668",
      name: "some updated name",
      reference: "some updated reference",
      selected: false
    }
    @invalid_attrs %{abbr: nil, archived: nil, description: nil, id: nil, name: nil, reference: nil, selected: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Listings.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Listings.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Listings.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Listings.create_item(@valid_attrs)
      assert item.abbr == "some abbr"
      assert item.archived == true
      assert item.description == "some description"
      assert item.id == "7488a646-e31f-11e4-aace-600308960662"
      assert item.name == "some name"
      assert item.reference == "some reference"
      assert item.selected == true
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listings.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Listings.update_item(item, @update_attrs)
      assert item.abbr == "some updated abbr"
      assert item.archived == false
      assert item.description == "some updated description"
      assert item.id == "7488a646-e31f-11e4-aace-600308960668"
      assert item.name == "some updated name"
      assert item.reference == "some updated reference"
      assert item.selected == false
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Listings.update_item(item, @invalid_attrs)
      assert item == Listings.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Listings.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Listings.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Listings.change_item(item)
    end
  end
end
