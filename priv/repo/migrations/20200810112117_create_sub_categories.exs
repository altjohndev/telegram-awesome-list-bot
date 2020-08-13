defmodule Talbot.Repo.Migrations.CreateSubCategories do
  use Ecto.Migration

  def change do
    create table(:sub_categories, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :abbr, :string
      add :description, :string

      add :chat_id, references(:chats, type: :uuid, on_delete: :delete_all), null: false
      add :category_id, references(:categories, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:sub_categories, [:chat_id])
    create index(:sub_categories, [:category_id])

    create unique_index(:sub_categories, [:abbr, :chat_id, :category_id])
  end
end
