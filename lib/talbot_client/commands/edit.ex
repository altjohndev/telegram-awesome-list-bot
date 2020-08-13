defmodule TalbotClient.Commands.Edit do
  @moduledoc """
  Command to update `Talbot.Listings`.
  """

  use TalbotClient.Pipeline
  import Recase, only: [to_snake: 1]
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> update_category(pipeline, data)
      {:ok, {:sub_category, data}} -> update_sub_category(pipeline, data)
      {:ok, {:item, data}} -> update_item(pipeline, data)
      {:error, error} -> set_error(pipeline, error)
    end
  end

  @category_fields ~w(abbr name description)
  @sub_category_fields ~w(abbr name description)
  @item_fields ~w(abbr name description reference selected archived subcategory)

  defp parse_input(input) do
    case String.split(input, " ", parts: 5) do
      [c_abbr, field, v1 | vn] when field in @category_fields ->
        {:ok, {:category, {to_snake(c_abbr), field, Enum.join([v1] ++ vn, " ")}}}

      [c_abbr, s_abbr, field, v1 | vn] when field in @sub_category_fields ->
        {:ok, {:sub_category, {to_snake(c_abbr), to_snake(s_abbr), field, Enum.join([v1] ++ vn, " ")}}}

      [c_abbr, ".", i_abbr, field, value] when field in @item_fields ->
        {:ok, {:item, {to_snake(c_abbr), to_snake(i_abbr), field, value}}}

      [c_abbr, s_abbr, i_abbr, field, value] when field in @item_fields ->
        {:ok, {:item, {to_snake(c_abbr), to_snake(s_abbr), to_snake(i_abbr), field, value}}}

      _ ->
        {:error, :invalid_edit_input}
    end
  end

  defp update_category(pipeline, {abbr, field, value}) do
    pipeline
    |> get_category(abbr)
    |> on_valid(&do_update_category(&1, field, value))
    |> append_message(&build_category_message(&1, field, value))
  end

  defp do_update_category(%{category: category} = pipeline, field, value) do
    case Listings.Categories.update(category, Map.put(%{}, field, value)) do
      {:ok, _category} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_update_category)
    end
  end

  defp build_category_message(%{category: %{name: name}}, field, value) do
    dgettext(
      @gettext_domain,
      "I succesfully updated the <b>%{name}</b> category field <b>%{field}</b> to <b>%{value}</b>!",
      name: name,
      field: field,
      value: value
    )
  end

  defp update_sub_category(pipeline, {category_abbr, abbr, field, value}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr)
    |> on_valid(&do_update_sub_category(&1, field, value))
    |> append_message(&build_sub_category_message(&1, field, value))
  end

  defp do_update_sub_category(%{sub_category: sub_category} = pipeline, field, value) do
    case Listings.SubCategories.update(sub_category, Map.put(%{}, field, value)) do
      {:ok, _sub_category} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_update_sub_category)
    end
  end

  defp build_sub_category_message(%{category: %{name: category_name}, sub_category: %{name: name}}, field, value) do
    dgettext(
      @gettext_domain,
      "I succesfully updated the <b>%{name}</b> (%{category_name}) sub-category field <b>%{field}</b> to <b>%{value}</b>!",
      name: name,
      category_name: category_name,
      field: field,
      value: value
    )
  end

  defp update_item(pipeline, {category_abbr, sub_category_abbr, abbr, field, value}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(sub_category_abbr)
    |> get_item(abbr)
    |> on_valid(&do_update_item(&1, field, value))
    |> append_message(&build_item_message(&1, field, value))
  end

  defp update_item(pipeline, {category_abbr, abbr, field, value}) do
    pipeline
    |> get_category(category_abbr)
    |> get_item(abbr)
    |> on_valid(&do_update_item(&1, field, value))
    |> append_message(&build_item_message(&1, field, value))
  end

  defp do_update_item(pipeline, "subcategory", ".") do
    do_update_item(pipeline, "sub_category_id", nil)
  end

  defp do_update_item(pipeline, "subcategory", value) do
    case get_sub_category(pipeline, value) do
      %{valid?: true, sub_category: %{id: s_id}} -> do_update_item(pipeline, "sub_category_id", s_id)
      pipeline -> pipeline
    end
  end

  defp do_update_item(%{item: item} = pipeline, field, value) do
    case Listings.Items.update(item, Map.put(%{}, field, value)) do
      {:ok, _item} -> pipeline
      {:error, error} -> set_changeset_error(pipeline, error, :failed_to_update_item)
    end
  end

  defp build_item_message(%{category: category, sub_category: %{name: sub_category_name}, item: item}, field, value) do
    dgettext(
      @gettext_domain,
      "I succesfully updated the <b>%{name}</b> (%{sub_category_name} - %{category_name}) item field <b>%{field}</b> to <b>%{value}</b>!",
      name: item.name,
      sub_category_name: sub_category_name,
      category_name: category.name,
      field: field,
      value: value
    )
  end

  defp build_item_message(%{category: %{name: category_name}, item: %{name: name}}, field, value) do
    dgettext(
      @gettext_domain,
      "I succesfully updated the <b>%{name}</b> (%{category_name}) item field <b>%{field}</b> to <b>%{value}</b>!",
      name: name,
      category_name: category_name,
      field: field,
      value: value
    )
  end
end
