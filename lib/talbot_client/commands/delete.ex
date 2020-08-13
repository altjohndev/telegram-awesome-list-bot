defmodule TalbotClient.Commands.Delete do
  @moduledoc """
  Command to delete `Talbot.Listings`.
  """

  use TalbotClient.Pipeline
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> delete_category(pipeline, data)
      {:ok, {:sub_category, data}} -> delete_sub_category(pipeline, data)
      {:ok, {:item, data}} -> delete_item(pipeline, data)
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
        {:error, :invalid_delete_input}
    end
  end

  defp delete_category(pipeline, abbr) do
    pipeline
    |> get_category(abbr)
    |> on_valid(&do_delete_category/1)
    |> append_message(&build_category_message/1)
  end

  defp do_delete_category(%{category: category} = pipeline) do
    case Listings.Categories.delete(category) do
      {:ok, _category} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_delete_category)
    end
  end

  defp build_category_message(%{category: category}) do
    dgettext(@gettext_domain, "I successfully removed the category <b>%{name}</b>.", name: category.name)
  end

  defp delete_sub_category(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr)
    |> on_valid(&do_delete_sub_category/1)
    |> append_message(&build_sub_category_message/1)
  end

  defp do_delete_sub_category(%{sub_category: sub_category} = pipeline) do
    case Listings.SubCategories.delete(sub_category) do
      {:ok, _sub_category} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_delete_sub_category)
    end
  end

  defp build_sub_category_message(%{category: category, sub_category: sub_category}) do
    dgettext(
      @gettext_domain,
      "I successfully removed the sub-category <b>%{name}</b> (%{category_name}).",
      name: sub_category.name,
      category_name: category.name
    )
  end

  defp delete_item(pipeline, {category_abbr, sub_category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(sub_category_abbr)
    |> get_item(abbr)
    |> on_valid(&do_delete_item/1)
    |> append_message(&build_item_message/1)
  end

  defp delete_item(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_item(abbr)
    |> on_valid(&do_delete_item/1)
    |> append_message(&build_item_message/1)
  end

  defp do_delete_item(%{item: item} = pipeline) do
    case Listings.Items.delete(item) do
      {:ok, _item} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_delete_item)
    end
  end

  defp build_item_message(%{category: category, sub_category: nil, item: item}) do
    dgettext(
      @gettext_domain,
      "I successfully removed the item <b>%{name}</b> (%{category_name}).",
      name: item.name,
      category_name: category.name
    )
  end

  defp build_item_message(%{category: category, sub_category: sub_category, item: item}) do
    dgettext(
      @gettext_domain,
      "I successfully removed the item <b>%{name}</b> (%{sub_category_name} - %{category_name}).",
      name: item.name,
      sub_category_name: sub_category.name,
      category_name: category.name
    )
  end
end
