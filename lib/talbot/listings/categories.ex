defmodule Talbot.Listings.Categories do
  @moduledoc """
  Manage `Talbot.Listings.Category`.
  """

  import Ecto.Query, only: [from: 2]
  alias Talbot.Listings.Category
  alias Talbot.Repo

  # List

  @spec list_from_chat(String.t(), any()) :: list(%Category{})
  def list_from_chat(chat_id, preloads \\ []) do
    from(c in Category, where: c.chat_id == ^chat_id, order_by: c.name)
    |> Repo.all()
    |> Repo.maybe_preload(preloads)
  end

  # Get

  @spec get_from_chat!(String.t(), String.t(), any()) :: %Category{}
  def get_from_chat!(chat_id, id, preloads \\ []) do
    Category
    |> Repo.get_by!(id: id, chat_id: chat_id)
    |> Repo.maybe_preload(preloads)
  end

  @spec get_from_chat_and_abbr!(String.t(), String.t(), any()) :: %Category{}
  def get_from_chat_and_abbr!(chat_id, abbr, preloads \\ []) do
    Category
    |> Repo.get_by!(abbr: abbr, chat_id: chat_id)
    |> Repo.maybe_preload(preloads)
  end

  # Create

  @spec create(map()) :: {:ok, %Category{}} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  # Update

  @spec update(%Category{}, map()) :: {:ok, %Category{}} | {:error, Ecto.Changeset.t()}
  def update(category, attrs) do
    category
    |> Category.update_changeset(attrs)
    |> Repo.update()
  end

  # Delete

  @spec delete(%Category{}) :: {:ok, %Category{}} | {:error, Ecto.Changeset.t()}
  def delete(category) do
    Repo.delete(category)
  end

  # Change

  @spec change(%Category{}, map()) :: Ecto.Changeset.t()
  def change(category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  # Preload

  @spec children_preloads :: list(atom)
  def children_preloads, do: [:sub_categories, :items]
end
