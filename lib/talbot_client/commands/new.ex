defmodule TalbotClient.Commands.New do
  @moduledoc """
  Command to create `Talbot.Listings`.
  """

  use TalbotClient.Pipeline
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> create_category(pipeline, data)
      {:ok, {:sub_category, data}} -> create_sub_category(pipeline, data)
      {:ok, {:item, data}} -> create_item(pipeline, data)
      {:error, error} -> set_error(pipeline, error)
    end
  end

  defp parse_input(input) do
    case String.split(input, " ", parts: 3) do
      [category_abbr] ->
        {:ok, {:category, Recase.to_snake(category_abbr)}}

      [category_abbr, sub_category_abbr] ->
        {:ok, {:sub_category, {Recase.to_snake(category_abbr), Recase.to_snake(sub_category_abbr)}}}

      [category_abbr, ".", item_abbr] ->
        {:ok, {:item, {Recase.to_snake(category_abbr), Recase.to_snake(item_abbr)}}}

      [category_abbr, sub_category_abbr, item_abbr] ->
        {:ok, {:item, {Recase.to_snake(category_abbr), Recase.to_snake(sub_category_abbr), Recase.to_snake(item_abbr)}}}

      _ ->
        {:error, :invalid_new_input}
    end
  end

  defp create_category(pipeline, abbr) do
    pipeline
    |> do_create_category(abbr)
    |> append_message(&build_category_message/1)
  end

  defp do_create_category(%{chat: %{id: chat_id}} = pipeline, abbr) do
    case Listings.Categories.create(%{chat_id: chat_id, abbr: abbr, name: abbr}) do
      {:ok, category} -> struct(pipeline, category: category)
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_create_category)
    end
  end

  defp build_category_message(%{category: %{name: name}}) do
    dgettext(@gettext_domain, "I succesfully created the <b>%{name}</b> category!", name: name)
  end

  defp create_sub_category(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> on_valid(&do_create_sub_category(&1, abbr))
    |> append_message(&build_sub_category_message/1)
  end

  defp do_create_sub_category(%{chat: %{id: chat_id}, category: %{id: category_id}} = pipeline, abbr) do
    case Listings.SubCategories.create(%{chat_id: chat_id, category_id: category_id, abbr: abbr, name: abbr}) do
      {:ok, sub_category} -> struct(pipeline, sub_category: sub_category)
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_create_sub_category)
    end
  end

  defp build_sub_category_message(%{category: %{name: category_name}, sub_category: %{name: name}}) do
    dgettext(
      @gettext_domain,
      "I succesfully created the <b>%{name}</b> (%{category_name}) sub-category!",
      name: name,
      category_name: category_name
    )
  end

  defp create_item(pipeline, {category_abbr, sub_category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(sub_category_abbr)
    |> on_valid(&do_create_item(&1, abbr))
    |> append_message(&build_item_message/1)
  end

  defp create_item(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> on_valid(&do_create_item(&1, abbr))
    |> append_message(&build_item_message/1)
  end

  defp do_create_item(%{chat: chat, category: category, sub_category: sub_category} = pipeline, abbr) do
    attrs = %{chat_id: chat.id, category_id: category.id, abbr: abbr, name: abbr}

    attrs =
      if sub_category != nil do
        Map.put(attrs, :sub_category_id, sub_category.id)
      else
        attrs
      end

    case Listings.Items.create(attrs) do
      {:ok, item} -> struct(pipeline, item: item)
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_create_item)
    end
  end

  defp build_item_message(%{category: %{name: c_name}, sub_category: %{name: s_name}, item: %{name: name}}) do
    dgettext(
      @gettext_domain,
      "I succesfully created the <b>%{name}</b> (%{sub_category_name} - %{category_name}) item!",
      name: name,
      sub_category_name: s_name,
      category_name: c_name
    )
  end

  defp build_item_message(%{category: %{name: category_name}, item: %{name: name}}) do
    dgettext(
      @gettext_domain,
      "I succesfully created the <b>%{name}</b> (%{category_name}) item!",
      name: name,
      category_name: category_name
    )
  end
end
