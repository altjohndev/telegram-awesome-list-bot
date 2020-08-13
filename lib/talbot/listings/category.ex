defmodule Talbot.Listings.Category do
  @moduledoc """
  Group of `Talbot.Listings.Item` from a `Talbot.Telegram.Chat`.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Talbot.{Listings, Telegram}
  alias Talbot.Listings.Category

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "categories" do
    field :name, :string
    field :abbr, :string
    field :description, :string

    belongs_to :chat, Telegram.Chat, type: Ecto.UUID

    has_many :sub_categories, Listings.SubCategory
    has_many :items, Listings.Item

    timestamps()
  end

  @doc false
  @spec changeset(%Category{}, map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :abbr, :description, :chat_id])
    |> validate_required([:name, :abbr, :chat_id])
    |> common_validations()
    |> unique_constraint([:abbr, :chat_id])
  end

  @doc false
  @spec update_changeset(%Category{}, map()) :: Ecto.Changeset.t()
  def update_changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :abbr, :description])
    |> validate_required([:name, :abbr])
    |> common_validations()
    |> unique_constraint([:abbr, :chat_id])
  end

  defp common_validations(changeset) do
    changeset
    |> update_change(:name, &format_name/1)
    |> validate_length(:name, max: 100)
    |> update_change(:abbr, &format_abbr/1)
    |> validate_length(:abbr, max: 20)
    |> update_change(:description, &format_description/1)
    |> validate_length(:description, max: 100)
  end

  defp format_name(nil), do: nil
  defp format_name(name), do: Recase.to_title(name)

  defp format_abbr(nil), do: nil
  defp format_abbr(abbr), do: Recase.to_snake(abbr)

  defp format_description(nil), do: nil
  defp format_description(description), do: Recase.to_sentence(description)
end
