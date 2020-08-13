defmodule Talbot.TelegramTest do
  use Talbot.DataCase

  alias Talbot.Telegram

  describe "chats" do
    alias Talbot.Telegram.Chat

    @valid_attrs %{
      chat_reference: 42,
      id: "7488a646-e31f-11e4-aace-600308960662",
      passcode: "some passcode",
      passcode_expires_at: ~N[2010-04-17 14:00:00]
    }
    @update_attrs %{
      chat_reference: 43,
      id: "7488a646-e31f-11e4-aace-600308960668",
      passcode: "some updated passcode",
      passcode_expires_at: ~N[2011-05-18 15:01:01]
    }
    @invalid_attrs %{chat_reference: nil, id: nil, passcode: nil, passcode_expires_at: nil}

    def chat_fixture(attrs \\ %{}) do
      {:ok, chat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Telegram.create_chat()

      chat
    end

    test "list_chats/0 returns all chats" do
      chat = chat_fixture()
      assert Telegram.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Telegram.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Telegram.create_chat(@valid_attrs)
      assert chat.chat_reference == 42
      assert chat.id == "7488a646-e31f-11e4-aace-600308960662"
      assert chat.passcode == "some passcode"
      assert chat.passcode_expires_at == ~N[2010-04-17 14:00:00]
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Telegram.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{} = chat} = Telegram.update_chat(chat, @update_attrs)
      assert chat.chat_reference == 43
      assert chat.id == "7488a646-e31f-11e4-aace-600308960668"
      assert chat.passcode == "some updated passcode"
      assert chat.passcode_expires_at == ~N[2011-05-18 15:01:01]
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = chat_fixture()
      assert {:error, %Ecto.Changeset{}} = Telegram.update_chat(chat, @invalid_attrs)
      assert chat == Telegram.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Telegram.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Telegram.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Telegram.change_chat(chat)
    end
  end
end
