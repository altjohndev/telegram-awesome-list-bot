defmodule Talbot.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :abbr, :string
      add :description, :string
      add :reference, :string

      add :archived, :boolean, default: false, null: false
      add :selected, :boolean, default: false, null: false

      add :chat_id, references(:chats, type: :uuid, on_delete: :delete_all), null: false
      add :category_id, references(:categories, type: :uuid, on_delete: :delete_all), null: false
      add :sub_category_id, references(:sub_categories, type: :uuid, on_delete: :nilify_all)

      timestamps()
    end

    create index(:items, [:chat_id])
    create index(:items, [:category_id])
    create index(:items, [:sub_category_id])

    create unique_index(:items, [:abbr, :chat_id, :category_id])
  end
end
