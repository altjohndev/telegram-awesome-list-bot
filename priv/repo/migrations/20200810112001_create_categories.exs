defmodule Talbot.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :name, :string
      add :abbr, :string
      add :description, :string

      add :chat_id, references(:chats, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:categories, [:chat_id])
    create unique_index(:categories, [:abbr, :chat_id])
  end
end
