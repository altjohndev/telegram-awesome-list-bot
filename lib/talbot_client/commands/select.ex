defmodule TalbotClient.Commands.Select do
  @moduledoc """
  Command to select `Talbot.Listings.Item`.
  """

  use TalbotClient.Pipeline
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> select_category(pipeline, data)
      {:ok, {:sub_category, data}} -> select_sub_category(pipeline, data)
      {:ok, {:item, data}} -> select_item(pipeline, data)
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
        {:error, :invalid_select_input}
    end
  end

  defp select_category(pipeline, abbr) do
    pipeline
    |> get_category(abbr, [:items])
    |> on_valid(&select_items_from_category/1)
    |> append_message(&build_category_message/1)
  end

  defp select_items_from_category(%{category: %{id: id, items: items}} = pipeline) do
    items = Enum.filter(items, &(not &1.archived))

    if Enum.all?(items, & &1.selected) do
      struct(pipeline, amount: -Listings.Items.deselect_all_from_category(id))
    else
      struct(pipeline, amount: Listings.Items.select_all_from_category(id))
    end
  end

  defp build_category_message(%{category: %{name: name}, amount: amount}) do
    cond do
      amount == 0 ->
        dgettext(
          @gettext_domain,
          "There is nothing to select or deselect from the category <b>%{name}</b>.",
          name: name
        )

      amount > 0 ->
        dngettext(
          @gettext_domain,
          "<code>%{count}</code> item was selected from the category <b>%{name}</b>.",
          "<code>%{count}</code> items were selected from the category <b>%{name}</b>.",
          amount,
          name: name
        )

      true ->
        dngettext(
          @gettext_domain,
          "<code>%{count}</code> item was deselected from the category <b>%{name}</b>.",
          "<code>%{count}</code> item were deselected from the category <b>%{name}</b>.",
          -amount,
          name: name
        )
    end
  end

  defp select_sub_category(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr, [:items])
    |> on_valid(&select_items_from_sub_category/1)
    |> append_message(&build_sub_category_message/1)
  end

  defp select_items_from_sub_category(%{sub_category: %{id: id, items: items}} = pipeline) do
    items = Enum.filter(items, &(not &1.archived))

    if Enum.all?(items, & &1.selected) do
      struct(pipeline, amount: -Listings.Items.deselect_all_from_sub_category(id))
    else
      struct(pipeline, amount: Listings.Items.select_all_from_sub_category(id))
    end
  end

  defp build_sub_category_message(%{sub_category: %{name: name}, category: %{name: category_name}, amount: amount}) do
    cond do
      amount == 0 ->
        dgettext(
          @gettext_domain,
          "There is nothing to select or deselect from the sub-category <b>%{name}</b> (%{category_name}).",
          name: name,
          category_name: category_name
        )

      amount > 0 ->
        dngettext(
          @gettext_domain,
          "<code>%{count}</code> item was selected from the sub-category <b>%{name}</b> (%{category_name}).",
          "<code>%{count}</code> items were selected from the sub-category <b>%{name}</b> (%{category_name}).",
          amount,
          name: name,
          category_name: category_name
        )

      true ->
        dngettext(
          @gettext_domain,
          "<code>%{count}</code> item was deselected from the sub-category <b>%{name}</b> (%{category_name}).",
          "<code>%{count}</code> item were deselected from the sub-category <b>%{name}</b> (%{category_name}).",
          -amount,
          name: name,
          category_name: category_name
        )
    end
  end

  defp select_item(pipeline, {category_abbr, sub_category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(sub_category_abbr)
    |> get_item(abbr)
    |> on_valid(&toggle_select/1)
    |> append_message(&build_item_message/1)
  end

  defp select_item(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_item(abbr)
    |> on_valid(&toggle_select/1)
    |> append_message(&build_item_message/1)
  end

  defp toggle_select(%{item: item} = pipeline) do
    case Listings.Items.toggle_select(item) do
      {:ok, item} -> struct(pipeline, item: item)
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_select_item)
    end
  end

  defp build_item_message(%{category: category, sub_category: nil, item: %{selected: true} = item}) do
    dgettext(
      @gettext_domain,
      "I successfully selected the item <b>%{name}</b> (%{category_name}).",
      name: item.name,
      category_name: category.name
    )
  end

  defp build_item_message(%{category: category, sub_category: nil, item: item}) do
    dgettext(
      @gettext_domain,
      "I successfully deselected the item <b>%{name}</b> (%{category_name}).",
      name: item.name,
      category_name: category.name
    )
  end

  defp build_item_message(%{category: category, sub_category: sub_category, item: %{selected: true} = item}) do
    dgettext(
      @gettext_domain,
      "I successfully selected the item <b>%{name}</b> (%{sub_category_name} - %{category_name}).",
      name: item.name,
      sub_category_name: sub_category.name,
      category_name: category.name
    )
  end

  defp build_item_message(%{category: category, sub_category: sub_category, item: item}) do
    dgettext(
      @gettext_domain,
      "I successfully deselected the item <b>%{name}</b> (%{sub_category_name} - %{category_name}).",
      name: item.name,
      sub_category_name: sub_category.name,
      category_name: category.name
    )
  end
end
