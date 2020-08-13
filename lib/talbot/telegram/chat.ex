defmodule Talbot.Telegram.Chat do
  @moduledoc """
  Reference of a chat entity from Telegram.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Talbot.Listings
  alias Talbot.Telegram.Chat

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "chats" do
    field :chat_reference, :integer

    field :passcode, :string
    field :passcode_expires_at, :naive_datetime

    field :locale, :string

    has_many :categories, Listings.Category
    has_many :sub_categories, Listings.SubCategory
    has_many :items, Listings.Item

    timestamps()
  end

  @doc false
  @spec changeset(%Chat{}, map()) :: Ecto.Changeset.t()
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:chat_reference, :locale])
    |> validate_required(:chat_reference)
    |> unique_constraint(:chat_reference)
    |> generate_passcode()
  end

  defp generate_passcode(changeset) do
    if changeset.valid? do
      changeset
      |> put_change(:passcode, Ecto.UUID.generate())
      |> put_change(
        :passcode_expires_at,
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(3600, :second)
        |> NaiveDateTime.truncate(:second)
      )
    else
      changeset
    end
  end

  @doc false
  @spec update_changeset(%Chat{}, map()) :: Ecto.Changeset.t()
  def update_changeset(chat, attrs) do
    cast(chat, attrs, [:locale])
  end
end
