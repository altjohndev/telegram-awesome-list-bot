defmodule TalbotClient.Commands.SelectRandom do
  @moduledoc """
  Command to random select `Talbot.Listings.Item`.
  """

  use TalbotClient.Pipeline
  alias Talbot.Listings

  @gettext_domain "client"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(%{command_input: input} = pipeline) do
    case parse_input(input) do
      {:ok, {:category, data}} -> select_category(pipeline, data)
      {:ok, {:sub_category, data}} -> select_sub_category(pipeline, data)
      {:error, error} -> set_error(pipeline, error)
    end
  end

  defp parse_input(input) do
    case String.split(input, " ", parts: 2) do
      [category_abbr] ->
        {:ok, {:category, Recase.to_snake(category_abbr)}}

      [category_abbr, "."] ->
        {:ok, {:category, Recase.to_snake(category_abbr)}}

      [category_abbr, sub_category_abbr] ->
        {:ok, {:sub_category, {Recase.to_snake(category_abbr), Recase.to_snake(sub_category_abbr)}}}

      _ ->
        {:error, :invalid_random_select_input}
    end
  end

  defp select_category(pipeline, abbr) do
    pipeline
    |> get_category(abbr, [:items])
    |> on_valid(&random_select_item(&1, &1.category.items))
    |> append_message(&build_category_message/1)
  end

  defp random_select_item(pipeline, items) do
    items = Enum.filter(items, &(not &1.selected and not &1.archived))

    if Enum.any?(items) do
      case Listings.Items.update(Enum.random(items), %{selected: true}) do
        {:ok, item} -> struct(pipeline, item: item)
        {:error, error} -> set_changeset_error(pipeline, error, :failed_to_select_item)
      end
    else
      set_error(pipeline, :no_item_to_select)
    end
  end

  defp build_category_message(%{category: %{name: category_name}, item: %{name: name}}) do
    dgettext(
      @gettext_domain,
      "I randomly selected the item <b>%{name}</b> from the category <b>%{category_name}</b>.",
      name: name,
      category_name: category_name
    )
  end

  defp select_sub_category(pipeline, {category_abbr, abbr}) do
    pipeline
    |> get_category(category_abbr)
    |> get_sub_category(abbr, [:items])
    |> on_valid(&random_select_item(&1, &1.sub_category.items))
    |> append_message(&build_sub_category_message/1)
  end

  defp build_sub_category_message(%{category: category, sub_category: sub_category, item: item}) do
    dgettext(
      @gettext_domain,
      "I randomly selected the item <b>%{name}</b> from the sub-category <b>%{category_name}</b> (%{sub_category_name}).",
      name: item.name,
      category_name: category.name,
      sub_category_name: sub_category.name
    )
  end
end
