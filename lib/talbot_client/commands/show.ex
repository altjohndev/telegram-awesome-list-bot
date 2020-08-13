defmodule TalbotClient.Commands.Show do
  @moduledoc """
  Command to show `Talbot.Listings`.
  """

  use TalbotClient.Pipeline

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> show_category(pipeline, data)
      {:ok, {:sub_category, data}} -> show_sub_category(pipeline, data)
      {:ok, {:item, data}} -> show_item(pipeline, data)
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
        {:error, :invalid_show_input}
    end
  end

  defp show_category(pipeline, abbr) do
    pipeline
    |> get_category(abbr, [:sub_categories, :items])
    |> append_message(&build_category_message/1)
  end

  defp build_category_message(%{category: category}) do
    dgettext(
      @gettext_domain,
      """
      I found your category!

      <b>%{name}</b>
      %{description}
      - Abbreviation: <code>%{abbr}</code>

      - Sub-categories: %{sub_categories_count}

      - Items: %{items_count}

      - Active items: %{active_items_count}

      - Active selected items: %{active_selected_items_count}

      - Archived items: %{archived_items_count}
      """,
      Keyword.merge(summarize_items(category.items),
        name: category.name,
        abbr: category.abbr,
        description: wrap_string(category.description),
        sub_categories_count: Enum.count(category.sub_categories)
      )
    )
  end

  defp wrap_string(string) do
    if string != nil do
      "\n#{string}\n"
    else
      ""
    end
  end

  defp summarize_items(items) do
    items_count = Enum.count(items)
    active_items_count = Enum.count(items, &(not &1.archived))
    active_selected_items_count = Enum.count(items, &(&1.selected and not &1.archived))
    archived_items_count = items_count - active_items_count

    [
      items: items,
      items_count: items_count,
      active_items_count: active_items_count,
      active_selected_items_count: active_selected_items_count,
      archived_items_count: archived_items_count
    ]
  end

  defp show_sub_category(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr, [:items])
    |> append_message(&build_sub_category_message/1)
  end

  defp build_sub_category_message(%{category: category, sub_category: sub_category}) do
    dgettext(
      @gettext_domain,
      """
      I found your sub-category!

      <b>%{name}</b>
      %{description}
      - Abbreviation: <code>%{abbr}</code>

      - Category: %{category_name}

      - Category abbreviation: <code>%{category_abbr}</code>

      - Items: %{items_count}

      - Active items: %{active_items_count}

      - Active selected items: %{active_selected_items_count}

      - Archived items: %{archived_items_count}
      """,
      Keyword.merge(summarize_items(sub_category.items),
        name: sub_category.name,
        description: wrap_string(sub_category.description),
        abbr: sub_category.abbr,
        category_name: category.name,
        category_abbr: category.abbr
      )
    )
  end

  defp show_item(pipeline, {category_abbr, sub_category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(sub_category_abbr)
    |> get_item(abbr)
    |> append_message(&build_item_message/1)
  end

  defp show_item(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_item(abbr)
    |> append_message(&build_item_message/1)
  end

  defp build_item_message(%{category: category, sub_category: nil, item: item}) do
    dgettext(
      @gettext_domain,
      """
      I found your item!

      <b>%{name}</b>
      %{reference}%{description}
      - Abbreviation: <code>%{abbr}</code>

      - Category: %{category_name}

      - Category abbreviation: <code>%{category_abbr}</code>

      - Selected: %{selected}

      - Archived: %{archived}
      """,
      name: item.name,
      reference: wrap_string(item.reference),
      description: wrap_string(item.description),
      abbr: item.abbr,
      category_name: category.name,
      category_abbr: category.abbr,
      selected: translate_boolean(item.selected),
      archived: translate_boolean(item.archived)
    )
  end

  defp build_item_message(%{category: category, sub_category: sub_category, item: item}) do
    dgettext(
      @gettext_domain,
      """
      I found your item!

      <b>%{name}</b>
      %{reference}%{description}
      - Abbreviation: <code>%{abbr}</code>

      - Category: %{category_name}

      - Category abbreviation: <code>%{category_abbr}</code>

      - Sub-category: %{sub_category_name}

      - Sub-category abbreviation: <code>%{sub_category_abbr}</code>

      - Selected: %{selected}

      - Archived: %{archived}
      """,
      name: item.name,
      reference: wrap_string(item.reference),
      description: wrap_string(item.description),
      abbr: item.abbr,
      category_name: category.name,
      category_abbr: category.abbr,
      sub_category_name: sub_category.name,
      sub_category_abbr: sub_category.abbr,
      selected: translate_boolean(item.selected),
      archived: translate_boolean(item.archived)
    )
  end

  defp translate_boolean(boolean) do
    if boolean do
      gettext("Yes")
    else
      gettext("No")
    end
  end
end
