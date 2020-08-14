defmodule Talbot.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :chat_reference, :bigint

      add :passcode, :string
      add :passcode_expires_at, :naive_datetime

      add :locale, :string

      timestamps()
    end

    create unique_index(:chats, :chat_reference)
  end
end
