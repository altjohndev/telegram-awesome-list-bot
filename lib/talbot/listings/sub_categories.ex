defmodule Talbot.Listings.SubCategories do
  @moduledoc """
  Manage `Talbot.Listings.SubCategory`.
  """

  import Ecto.Query, only: [from: 2]
  alias Talbot.Listings.SubCategory
  alias Talbot.Repo

  # List

  @spec list_from_chat(String.t(), any()) :: list(%SubCategory{})
  def list_from_chat(chat_id, preloads \\ []) do
    from(s in SubCategory, where: s.chat_id == ^chat_id, order_by: s.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  @spec list_from_category(String.t(), any()) :: list(%SubCategory{})
  def list_from_category(category_id, preloads \\ []) do
    from(s in SubCategory, where: s.category_id == ^category_id, order_by: s.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  # Get

  @spec get_from_chat!(String.t(), String.t(), any()) :: %SubCategory{}
  def get_from_chat!(chat_id, id, preloads \\ []) do
    SubCategory
    |> Repo.get_by!(id: id, chat_id: chat_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_category!(String.t(), String.t(), any()) :: %SubCategory{}
  def get_from_category!(category_id, id, preloads \\ []) do
    SubCategory
    |> Repo.get_by!(id: id, category_id: category_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_category_and_abbr!(String.t(), String.t(), any()) :: %SubCategory{}
  def get_from_category_and_abbr!(category_id, abbr, preloads \\ []) do
    SubCategory
    |> Repo.get_by!(abbr: abbr, category_id: category_id)
    |> Repo.maybe_preload(preloads)
  end

  # Create

  @spec create(map()) :: {:ok, %SubCategory{}} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %SubCategory{}
    |> SubCategory.changeset(attrs)
    |> Repo.insert()
  end

  # Update

  @spec update(%SubCategory{}, map()) :: {:ok, %SubCategory{}} | {:error, Ecto.Changeset.t()}
  def update(sub_category, attrs) do
    sub_category
    |> SubCategory.update_changeset(attrs)
    |> Repo.update()
  end

  # Delete

  @spec delete(%SubCategory{}) :: {:ok, %SubCategory{}} | {:error, Ecto.Changeset.t()}
  def delete(sub_category) do
    Repo.delete(sub_category)
  end

  # Change

  @spec change(%SubCategory{}, map()) :: Ecto.Changeset.t()
  def change(sub_category, attrs \\ %{}) do
    SubCategory.changeset(sub_category, attrs)
  end

  # Preload

  @spec children_preloads :: list(atom)
  def children_preloads, do: [:items]
end
