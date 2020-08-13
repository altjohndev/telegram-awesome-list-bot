defmodule TalbotClient.Pipeline do
  @moduledoc """
  Handle command tasks and data.
  """

  require Logger
  require Talbot.Gettext
  alias Nadia.Model.Update
  alias Talbot.{Gettext, Listings, Telegram}
  alias TalbotClient.Pipeline

  @gettext_domain "client"

  @type t :: %Pipeline{
          amount: integer(),
          categories: list(%Listings.Category{}),
          category: %Listings.Category{} | nil,
          chat_reference: integer() | nil,
          changeset: Ecto.Changeset.t() | nil,
          chat: %Telegram.Chat{} | nil,
          command_input: String.t(),
          command: String.t() | nil,
          error: atom(),
          from_name: String.t(),
          item: %Listings.Item{} | nil,
          items: list(%Listings.Item{}),
          message_id: integer() | nil,
          message: String.t(),
          sub_categories: list(%Listings.SubCategory{}),
          sub_category: %Listings.SubCategory{},
          update_type: :inline_query | :callback_query | :message | :edited_message | :channel_post,
          update: Update.t(),
          valid?: boolean()
        }

  defstruct amount: 0,
            categories: [],
            category: nil,
            changeset: nil,
            chat_reference: nil,
            chat: nil,
            command_input: "",
            command: nil,
            error: nil,
            from_name: "",
            item: nil,
            items: [],
            message_id: nil,
            message: "",
            sub_categories: [],
            sub_category: nil,
            update_type: nil,
            update: nil,
            valid?: true

  @spec __using__(any()) :: {:__block__, list(), list()}
  defmacro __using__(_opts) do
    quote do
      import Pipeline
      import Talbot.Gettext
    end
  end

  @spec append_message(Pipeline.t(), (Pipeline.t() -> String.t())) :: Pipeline.t()
  def append_message(pipeline, function) do
    on_valid(pipeline, &do_append_message(&1, function))
  end

  defp do_append_message(pipeline, function) do
    struct(pipeline, message: pipeline.message <> function.(pipeline))
  end

  @spec get_category(Pipeline.t(), String.t(), any()) :: Pipeline.t()
  def get_category(pipeline, abbr, preloads \\ []) do
    on_valid(pipeline, &do_get_category(&1, abbr, preloads))
  end

  defp do_get_category(%{chat: %{id: chat_id}} = pipeline, abbr, preloads) do
    struct(pipeline, category: Listings.Categories.get_from_chat_and_abbr!(chat_id, abbr, preloads))
  rescue
    _error -> set_error(pipeline, :category_not_found)
  end

  @spec get_item(Pipeline.t(), String.t()) :: Pipeline.t()
  def get_item(pipeline, abbr) do
    on_valid(pipeline, &do_get_item(&1, abbr))
  end

  defp do_get_item(%{sub_category: %{id: sub_category_id}} = pipeline, abbr) do
    struct(pipeline, item: Listings.Items.get_from_sub_category_and_abbr!(sub_category_id, abbr))
  rescue
    _error -> set_error(pipeline, :item_not_found)
  end

  defp do_get_item(%{category: %{id: category_id}} = pipeline, abbr) do
    struct(pipeline, item: Listings.Items.get_from_category_and_abbr!(category_id, abbr))
  rescue
    _error -> set_error(pipeline, :item_not_found)
  end

  @spec get_sub_category(Pipeline.t(), String.t(), any()) :: Pipeline.t()
  def get_sub_category(pipeline, abbr, preloads \\ []) do
    on_valid(pipeline, &do_get_sub_category(&1, abbr, preloads))
  end

  defp do_get_sub_category(%{category: %{id: category_id}} = pipeline, abbr, preloads) do
    struct(pipeline, sub_category: Listings.SubCategories.get_from_category_and_abbr!(category_id, abbr, preloads))
  rescue
    _error -> set_error(pipeline, :sub_category_not_found)
  end

  @spec on_valid(Pipeline.t(), (Pipeline.t() -> Pipeline.t())) :: Pipeline.t()
  def on_valid(pipeline, function) do
    if pipeline.valid? do
      function.(pipeline)
    else
      pipeline
    end
  rescue
    error ->
      Logger.error("Telegram client pipeline failed, exception is: #{inspect(error)}")
      Logger.debug(inspect({pipeline, function}))
      set_error(pipeline, :raised_exception)
  end

  @spec send_message(Pipeline.t()) :: Pipeline.t()
  def send_message(pipeline) do
    message =
      if pipeline.valid? do
        Gettext.dgettext(@gettext_domain, "Hi, %{name}.", name: pipeline.from_name) <> " " <> pipeline.message
      else
        message = TalbotClient.ErrorMessages.get(pipeline.error)

        case pipeline.changeset do
          nil -> message
          changeset -> message <> TalbotClient.ErrorHelpers.changeset_message(changeset)
        end
      end

    opts = [parse_mode: "HTML", reply_to_message_id: pipeline.message_id]

    case Nadia.send_message(pipeline.chat_reference, message, opts) do
      {:ok, _message} ->
        pipeline

      {:error, error} ->
        Logger.error("Failed to send message, error is: #{inspect(error)}")
        set_error(pipeline, :failed_to_send_message)
    end
  rescue
    error ->
      Logger.error("Failed to send message, error is: #{inspect(error)}")
      set_error(pipeline, :failed_to_send_message)
  end

  @spec set_changeset_error(Pipeline.t(), Ecto.Changeset.t(), atom()) :: Pipeline.t()
  def set_changeset_error(pipeline, changeset, error) do
    struct(pipeline, valid?: false, changeset: changeset, error: error)
  end

  @spec set_error(Pipeline.t(), atom()) :: Pipeline.t()
  def set_error(pipeline, error) do
    struct(pipeline, valid?: false, error: error)
  end

  @spec start(Update.t()) :: Pipeline.t()
  def start(update) do
    %Pipeline{}
    |> struct(update: update)
    |> get_chat_reference()
    |> on_valid(&get_command_and_command_input/1)
    |> on_valid(&get_from_name/1)
    |> on_valid(&get_message_id/1)
    |> on_valid(&fetch_chat/1)
  end

  defp get_chat_reference(pipeline) do
    case pipeline.update do
      %{inline_query: inline_query} when not is_nil(inline_query) ->
        struct(pipeline, chat_reference: inline_query.from.id, update_type: :inline_query)

      %{callback_query: callback_query} when not is_nil(callback_query) ->
        struct(pipeline, chat_reference: callback_query.message.chat.id, update_type: :callback_query)

      %{message: %{chat: %{id: id}}} when not is_nil(id) ->
        struct(pipeline, chat_reference: id, update_type: :message)

      %{edited_message: %{chat: %{id: id}}} when not is_nil(id) ->
        struct(pipeline, chat_reference: id, update_type: :edited_message)

      %{channel_post: %{chat: %{id: id}}} ->
        struct(pipeline, chat_reference: id, update_type: :channel_post)

      _ ->
        set_error(pipeline, :unknown_update_type)
    end
  end

  defp get_command_and_command_input(pipeline) do
    case pipeline.update_type do
      :message -> do_get_command_and_command_input(pipeline, pipeline.update.message.text)
      _ -> set_error(pipeline, :failed_to_identify_command)
    end
  end

  defp do_get_command_and_command_input(pipeline, text) do
    case String.split(text, " ", parts: 2) do
      ["/" <> command, command_input] -> struct(pipeline, command: parse_command(command), command_input: command_input)
      ["/" <> command] -> struct(pipeline, command: parse_command(command))
      _error -> set_error(pipeline, :failed_to_parse_command)
    end
  end

  defp parse_command(command) do
    case String.split(command, "@", parts: 2) do
      [command, _bot_name] -> command
      [command] -> command
    end
  end

  defp get_from_name(pipeline) do
    case pipeline.update_type do
      :message -> struct(pipeline, from_name: pipeline.update.message.from.first_name)
      _ -> set_error(pipeline, :failed_to_identify_from_name)
    end
  end

  defp get_message_id(pipeline) do
    case pipeline.update_type do
      :message -> struct(pipeline, message_id: pipeline.update.message.message_id)
      _ -> set_error(pipeline, :failed_to_identity_message_id)
    end
  end

  defp fetch_chat(pipeline) do
    case Telegram.Chats.fetch(pipeline.chat_reference) do
      {:ok, chat} ->
        Gettext.update_locale(chat.locale)
        struct(pipeline, chat: chat)

      _error ->
        set_error(pipeline, :failed_to_fetch_chat)
    end
  end
end
