defmodule Talbot.Listings.Items do
  @moduledoc """
  Manage `Talbot.Listings.Item`.
  """

  import Ecto.Query, only: [from: 2]
  alias Talbot.Listings.Item
  alias Talbot.Repo

  # List

  @spec list_from_chat(String.t(), any()) :: list(%Item{})
  def list_from_chat(chat_id, preloads \\ []) do
    from(i in Item, where: i.chat_id == ^chat_id, order_by: i.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  @spec list_from_category(String.t(), any()) :: list(%Item{})
  def list_from_category(category_id, preloads \\ []) do
    from(i in Item, where: i.category_id == ^category_id, order_by: i.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  @spec list_from_sub_category(String.t(), any()) :: list(%Item{})
  def list_from_sub_category(sub_category_id, preloads \\ []) do
    from(i in Item, where: i.sub_category_id == ^sub_category_id, order_by: i.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  # Get

  @spec get_from_chat!(String.t(), String.t(), any()) :: %Item{}
  def get_from_chat!(chat_id, id, preloads \\ []) do
    Item
    |> Repo.get_by!(id: id, chat_id: chat_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_category!(String.t(), String.t(), any()) :: %Item{}
  def get_from_category!(category_id, id, preloads \\ []) do
    Item
    |> Repo.get_by!(id: id, category_id: category_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_category_and_abbr!(String.t(), String.t(), any()) :: %Item{}
  def get_from_category_and_abbr!(category_id, abbr, preloads \\ []) do
    Item
    |> Repo.get_by!(abbr: abbr, category_id: category_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_sub_category!(String.t(), String.t(), any()) :: %Item{}
  def get_from_sub_category!(sub_category_id, id, preloads \\ []) do
    Item
    |> Repo.get_by!(id: id, sub_category_id: sub_category_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_sub_category_and_abbr!(String.t(), String.t(), any()) :: %Item{}
  def get_from_sub_category_and_abbr!(sub_category_id, abbr, preloads \\ []) do
    Item
    |> Repo.get_by!(abbr: abbr, sub_category_id: sub_category_id)
    |> Repo.maybe_preload(preloads)
  end

  # Create

  @spec create(map()) :: {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  # Update

  @spec update(%Item{}, map()) :: {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def update(item, attrs) do
    item
    |> Item.update_changeset(attrs)
    |> Repo.update()
  end

  @spec dearchive_all_from_category(String.t()) :: integer()
  def dearchive_all_from_category(category_id) do
    {entries, _nil} =
      from(i in Item, where: i.category_id == ^category_id and i.archived == true)
      |> Repo.update_all(set: [archived: false])

    entries
  end

  @spec dearchive_all_from_sub_category(String.t()) :: integer()
  def dearchive_all_from_sub_category(sub_category_id) do
    {entries, _nil} =
      from(i in Item, where: i.sub_category_id == ^sub_category_id and i.archived == true)
      |> Repo.update_all(set: [archived: false])

    entries
  end

  @spec archive_all_from_category(String.t()) :: integer()
  def archive_all_from_category(category_id) do
    {entries, _result} =
      from(i in Item, where: i.category_id == ^category_id and i.archived == false)
      |> Repo.update_all(set: [archived: true])

    entries
  end

  @spec archive_all_from_sub_category(String.t()) :: integer()
  def archive_all_from_sub_category(sub_category_id) do
    {entries, _result} =
      from(i in Item, where: i.sub_category_id == ^sub_category_id and i.archived == false)
      |> Repo.update_all(set: [archived: true])

    entries
  end

  @spec toggle_archive(%Item{}) :: {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def toggle_archive(%{archived: archived} = item) do
    update(item, %{archived: not archived})
  end

  @spec deselect_all_from_category(String.t()) :: integer()
  def deselect_all_from_category(category_id) do
    {entries, _nil} =
      from(i in Item, where: i.category_id == ^category_id and i.selected == true)
      |> Repo.update_all(set: [selected: false])

    entries
  end

  @spec deselect_all_from_sub_category(String.t()) :: integer()
  def deselect_all_from_sub_category(sub_category_id) do
    {entries, _nil} =
      from(i in Item, where: i.sub_category_id == ^sub_category_id and i.selected == true)
      |> Repo.update_all(set: [selected: false])

    entries
  end

  @spec select_all_from_category(String.t()) :: integer()
  def select_all_from_category(category_id) do
    {entries, _result} =
      from(i in Item, where: i.category_id == ^category_id and i.selected == false)
      |> Repo.update_all(set: [selected: true])

    entries
  end

  @spec select_all_from_sub_category(String.t()) :: integer()
  def select_all_from_sub_category(sub_category_id) do
    {entries, _result} =
      from(i in Item, where: i.sub_category_id == ^sub_category_id and i.selected == false)
      |> Repo.update_all(set: [selected: true])

    entries
  end

  @spec toggle_select(%Item{}) :: {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def toggle_select(%{selected: selected} = item) do
    update(item, %{selected: not selected})
  end

  # Delete

  @spec delete(%Item{}) :: {:ok, %Item{}} | {:error, Ecto.Changeset.t()}
  def delete(item) do
    Repo.delete(item)
  end

  # Change

  @spec change(%Item{}, map()) :: Ecto.Changeset.t()
  def change(item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  # Preload

  @spec parents_preloads :: list(atom)
  def parents_preloads, do: [:sub_category, :category]
end
