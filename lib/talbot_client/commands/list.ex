defmodule TalbotClient.Commands.List do
  @moduledoc """
  Command to list `Talbot.Listings`.
  """

  use TalbotClient.Pipeline
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t(), boolean()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline, with_abbr? \\ false) do
    case parse_input(input) do
      {:ok, :categories} -> list_categories(pipeline, with_abbr?)
      {:ok, {:category, data}} -> list_from_category(pipeline, data, with_abbr?)
      {:ok, {:sub_category, data}} -> list_from_sub_category(pipeline, data, with_abbr?)
    end
  end

  defp parse_input(input) do
    case String.split(input, " ", parts: 2) do
      [""] ->
        {:ok, :categories}

      [category_abbr] ->
        {:ok, {:category, Recase.to_snake(category_abbr)}}

      [category_abbr, sub_category_abbr] ->
        {:ok, {:sub_category, {Recase.to_snake(category_abbr), Recase.to_snake(sub_category_abbr)}}}
    end
  end

  defp list_categories(pipeline, with_abbr?) do
    pipeline
    |> get_categories()
    |> append_message(&build_categories_message(&1, with_abbr?))
  end

  defp get_categories(%{chat: %{id: chat_id}} = pipeline) do
    struct(pipeline, categories: Listings.Categories.list_from_chat(chat_id))
  end

  defp build_categories_message(%{categories: []}, _with_abbr?) do
    dgettext(@gettext_domain, "This chat does not have any category.")
  end

  defp build_categories_message(%{categories: categories}, with_abbr?) do
    dgettext(@gettext_domain, "Your categories are:") <> "\n\n" <> build_categories_list(categories, with_abbr?)
  end

  defp build_categories_list(categories, with_abbr?) do
    categories
    |> Enum.with_index(1)
    |> Enum.map(&build_element(&1, with_abbr?))
    |> Enum.join("\n")
  end

  defp build_element({%{name: name, abbr: abbr}, index}, with_abbr?) do
    message = "#{index}. #{name}"

    if with_abbr? do
      message <> " (<code>#{abbr}</code>)"
    else
      message
    end
  end

  defp list_from_category(pipeline, abbr, with_abbr?) do
    pipeline
    |> get_category(abbr, [:sub_categories, items: [:sub_category]])
    |> append_message(&build_category_message(&1, with_abbr?))
  end

  defp build_category_message(%{category: %{sub_categories: [], items: []}}, _with_abbr?) do
    dgettext(@gettext_domain, "This category does not have any sub-category or item.")
  end

  defp build_category_message(%{category: %{sub_categories: sub_categories, items: []} = category}, with_abbr?) do
    dgettext(@gettext_domain, "The <b>%{category_name}</b> sub-categories are:", category_name: category.name) <>
      "\n\n" <> build_categories_list(sub_categories, with_abbr?)
  end

  defp build_category_message(%{category: %{sub_categories: [], items: items} = category}, with_abbr?) do
    dgettext(@gettext_domain, "The <b>%{category_name}</b> items are:", category_name: category.name) <>
      "\n\n" <> build_items_list(items, with_abbr?)
  end

  defp build_category_message(%{category: %{sub_categories: sub_categories, items: items} = category}, with_abbr?) do
    dgettext(@gettext_domain, "The <b>%{category_name}</b> sub-categories are:", category_name: category.name) <>
      "\n\n" <>
      build_categories_list(sub_categories, with_abbr?) <>
      "\n\n" <>
      dgettext(@gettext_domain, "The <b>%{category_name}</b> items are:", category_name: category.name) <>
      "\n\n" <> build_items_list(items, with_abbr?)
  end

  defp build_items_list(items, with_abbr?) do
    items
    |> Enum.with_index(1)
    |> Enum.map(&build_item(&1, with_abbr?))
    |> Enum.join("\n")
  end

  defp build_item({item, index}, with_abbr?) do
    selected =
      if item.selected do
        "X"
      else
        " "
      end

    message = "<code>[#{selected}]</code> #{index}. #{item.name}"

    message =
      cond do
        with_abbr? -> message <> " (<code>#{item.abbr}</code>)"
        item.sub_category != nil -> message <> " (#{item.sub_category.name})"
        true -> message
      end

    if item.archived do
      "<s>#{message}</s>"
    else
      message
    end
  end

  defp list_from_sub_category(pipeline, {category_abbr, abbr}, with_abbr?) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr, items: [:sub_category])
    |> append_message(&build_sub_category_message(&1, with_abbr?))
  end

  defp build_sub_category_message(%{sub_category: %{items: []}}, _with_abbr?) do
    dgettext(@gettext_domain, "This sub-category does not have any item.")
  end

  defp build_sub_category_message(%{category: category, sub_category: %{items: items} = sub_category}, with_abbr?) do
    dgettext(
      @gettext_domain,
      "The <b>%{sub_category_name}</b> (%{category_name}) items are:",
      sub_category_name: sub_category.name,
      category_name: category.name
    ) <>
      "\n\n" <> build_items_list(items, with_abbr?)
  end
end
