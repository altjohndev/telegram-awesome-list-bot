defmodule Talbot.Telegram.Chats do
  @moduledoc """
  Manage `Talbot.Telegram.Chat`.
  """

  alias Talbot.Repo
  alias Talbot.Telegram.Chat

  # Fetch

  @spec fetch(integer(), any()) :: {:ok, %Chat{}} | {:error, any()}
  def fetch(chat_reference, preloads \\ []) do
    case get_or_create_by_reference(chat_reference) do
      {:ok, chat} -> {:ok, Repo.maybe_preload(chat, preloads)}
      error -> error
    end
  end

  defp get_or_create_by_reference(chat_reference) do
    case Repo.get_by(Chat, chat_reference: chat_reference) do
      nil -> create(%{chat_reference: chat_reference})
      chat -> {:ok, chat}
    end
  end

  # Get

  @spec get!(String.t(), any()) :: %Chat{}
  def get!(id, preloads \\ []) do
    Chat
    |> Repo.get!(id)
    |> Repo.maybe_preload(preloads)
  end

  # Create

  @spec create(map()) :: {:ok, %Chat{}} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  # Update

  @spec update(%Chat{}, map()) :: {:ok, %Chat{}} | {:error, Ecto.Changeset.t()}
  def update(chat, attrs) do
    chat
    |> Chat.update_changeset(attrs)
    |> Repo.update()
  end

  @spec update_passcode(%Chat{}) :: {:ok, %Chat{}} | {:error, Ecto.Changeset.t()}
  def update_passcode(chat) do
    chat
    |> Chat.changeset(%{})
    |> Repo.update()
  end

  # Delete

  @spec delete(%Chat{}) :: {:ok, %Chat{}} | {:error, Ecto.Changeset.t()}
  def delete(chat) do
    Repo.delete(chat)
  end

  # Change

  @spec change(%Chat{}, map()) :: Ecto.Changeset.t()
  def change(chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

  # Preload

  @spec full_depth_preloads :: list()
  def full_depth_preloads, do: [categories: [:sub_categories, [items: :sub_category]]]
end
