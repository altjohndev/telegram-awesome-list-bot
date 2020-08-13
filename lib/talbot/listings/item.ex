defmodule Talbot.Listings.Item do
  @moduledoc """
  Listings entry.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Talbot.{Listings, Telegram}
  alias Talbot.Listings.Item

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "items" do
    field :name, :string
    field :abbr, :string
    field :description, :string
    field :reference, :string

    field :archived, :boolean, default: false
    field :selected, :boolean, default: false

    belongs_to :chat, Telegram.Chat, type: Ecto.UUID
    belongs_to :category, Listings.Category, type: Ecto.UUID
    belongs_to :sub_category, Listings.SubCategory, type: Ecto.UUID

    timestamps()
  end

  @doc false
  @spec changeset(%Item{}, map()) :: Ecto.Changeset.t()
  def changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :abbr,
      :description,
      :reference,
      :selected,
      :archived,
      :chat_id,
      :category_id,
      :sub_category_id
    ])
    |> validate_required([:name, :abbr, :chat_id, :category_id])
    |> common_validations()
    |> unique_constraint([:abbr, :chat_id, :category_id])
  end

  @doc false
  @spec update_changeset(%Item{}, map()) :: Ecto.Changeset.t()
  def update_changeset(item, attrs) do
    item
    |> cast(attrs, [
      :name,
      :abbr,
      :description,
      :reference,
      :selected,
      :archived,
      :category_id,
      :sub_category_id
    ])
    |> validate_required([:name, :abbr, :category_id])
    |> common_validations()
    |> unique_constraint([:abbr, :chat_id, :category_id])
  end

  defp common_validations(changeset) do
    changeset
    |> update_change(:name, &format_name/1)
    |> validate_length(:name, max: 100)
    |> update_change(:abbr, &format_abbr/1)
    |> validate_length(:abbr, max: 20)
    |> update_change(:description, &format_description/1)
    |> validate_length(:description, max: 100)
    |> validate_length(:reference, max: 100)
  end

  defp format_name(nil), do: nil
  defp format_name(name), do: Recase.to_title(name)

  defp format_abbr(nil), do: nil
  defp format_abbr(abbr), do: Recase.to_snake(abbr)

  defp format_description(nil), do: nil
  defp format_description(description), do: Recase.to_sentence(description)
end
