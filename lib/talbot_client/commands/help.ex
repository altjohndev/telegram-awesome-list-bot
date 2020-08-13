defmodule TalbotClient.Commands.Help do
  @moduledoc """
  Command to explain how to use the bot.
  """

  use TalbotClient.Pipeline

  @gettext_domain "client_help"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def handle_message(%{command_input: input} = pipeline) do
    case input do
      "category" -> append_message(pipeline, &category_message/1)
      "subcategory" -> append_message(pipeline, &sub_category_message/1)
      "item" -> append_message(pipeline, &item_message/1)
      "abbr" -> append_message(pipeline, &abbr_message/1)
      "name" -> append_message(pipeline, &name_message/1)
      "description" -> append_message(pipeline, &description_message/1)
      "reference" -> append_message(pipeline, &reference_message/1)
      "archived" -> append_message(pipeline, &archived_message/1)
      "selected" -> append_message(pipeline, &selected_message/1)
      _ -> append_message(pipeline, &default_message/1)
    end
  end

  defp default_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      My purpose is to manage categories, their sub-categories, and their items.

      A category is a collection of sub-categories and items. To learn more about categories, use the command:

      <code>/help category</code>

      A sub-category is a collection of items from a category. To learn more about sub-categories, use the command:

      <code>/help subcategory</code>

      An item is something that can be listed, selected, and archived. It is always associated with a category, and can be associated with a sub-category from the category. To learn more about items, use the command:

      <code>/help item</code>

      For example of usage, the command /start can guide you.
      """
    )
  end

  defp category_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      A category is a collection of sub-categories and items.

      <b>- Creating a category</b>

      A category is identified according to the abbreviation (<code>abbr</code>) defined on creation. To learn more about <code>abbr</code>, use the command:

      <code>/help abbr</code>

      To create a new category, use the command /n (or /new ). The pattern is:

      <code>/n {abbr}</code>

      For example:

      <code>/n movies</code>

      Will create a category with the abbreviation <b>movies</b>.

      <b>- Updating a category</b>

      It is possible to set a custom name (<code>name</code>) and a description (<code>description</code>) on update.

      To learn more about <code>name</code>, use the command:

      <code>/help name</code>

      To learn more about <code>description</code>, use the command:

      <code>/help description</code>

      To update a category, use the command /e (or /edit ). The pattern is:

      <code>/e {abbr} {change_what} {the_change}</code>

      For example:

      <code>/e movies description A catalog of movies to watch</code>

      Will update the description of the category with the abbreviation <b>movies</b> to "A catalog of movies to watch".

      The fields you can change are: <code>abbr</code>, <code>name</code>, and <code>description</code>

      <b>- Listing categories</b>

      To list all categories, use the command /l (or /list ).

      To get a list with <code>abbr</code> included, use the command /la (or /listwithabbr ).

      <b>- Removing a category</b>

      To remove a category, use the command /d (or /delete ). The pattern is:

      <code>/d {abbr}</code>

      For example:

      <code>/d movies</code>

      Will remove the category with abbreviation as <b>movies</b>.

      <b>- Information about a category</b>

      To show more information about a category, use the command /s (or /show). The pattern is:

      <code>/s {abbr}</code>

      For example:

      <code>/s movies</code>

      Will show detailed information about the category with abbreviation as <b>movies</b>.
      """
    )
  end

  defp sub_category_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      A sub-category is a collection of items from a category.

      <b>- Creating a sub-category</b>

      A sub-category is identified according to the abbreviation (<code>abbr</code>) defined on creation. To learn more about <code>abbr</code>, use the command:

      <code>/help abbr</code>

      To create a new sub-category, use the command /n (or /new ). The pattern is:

      <code>/n {category_abbr} {abbr}</code>

      For example:

      <code>/n movies drama</code>

      Will create a sub-category with the abbreviation <b>drama</b> from the category with the abbreviation <b>movies</b>.

      <b>- Updating a sub-category</b>

      It is possible to set a custom name (<code>name</code>) and a description (<code>description</code>) on update.

      To learn more about <code>name</code>, use the command:

      <code>/help name</code>

      To learn more about <code>description</code>, use the command:

      <code>/help description</code>

      To update a sub-category, use the command /e (or /edit ). The pattern is:

      <code>/e {category_abbr} {abbr} {change_what} {the_change}</code>

      For example:

      <code>/e movies drama description Movies to cry a river</code>

      Will update the description of the sub-category with the abbreviation <b>drama</b> from the category with the abbreviation <b>movies</b> to "Movies to cry a river".

      The fields you can change are: <code>abbr</code>, <code>name</code>, and <code>description</code>

      <b>- Listing sub-categories</b>

      To list all sub-categories from a category, use the command /l (or /list ). The pattern is:

      <code>/l {category_abbr}</code>

      For example:

      <code>/l movies</code>

      Will list all sub-categories from the category with the abbreviation as <b>movies</b>.

      To get a list with <code>abbr</code> included, use the command /la (or /listwithabbr ).

      <b>- Removing a sub-category</b>

      To remove a sub-category, use the command /d (or /delete ). The pattern is:

      <code>/d {category_abbr} {abbr}</code>

      For example:

      <code>/d movies drama</code>

      Will remove the sub-category with abbreviation as <b>drama</b> from the category with abbreviation as <b>movies</b>.

      <b>- Information about a sub-category</b>

      To show more information about a sub-category, use the command /s (or /show). The pattern is:

      <code>/s {category_abbr} {abbr}</code>

      For example:

      <code>/s movies drama</code>

      Will show detailed information about the sub-category with abbreviation as <b>drama</b> from the category with abbreviation as <b>movies</b>.
      """
    )
  end

  defp item_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      An item is something that can be listed, selected, and archived. It is always associated with a category, and can be associated with a sub-category from the category.

      <b>- Creating an item</b>

      An item is identified according to the abbreviation (<code>abbr</code>) defined on creation. To learn more about <code>abbr</code>, use the command:

      <code>/help abbr</code>

      To create a new item, use the command /n (or /new ). The pattern is:

      <code>/n {category_abbr} {sub_category_abbr} {abbr}</code>

      For example:

      <code>/n movies drama ai</code>

      Will create an item with the abbreviation <b>ai</b>.

      To create an item without a sub-category, simply replace the <code>{sub_category_abbr}</code> with <code>.</code> (a dot). This statement is valid for every command related to items.

      <b>- Updating an item</b>

      It is possible to set a custom name (<code>name</code>), description (<code>description</code>), reference (<code>reference</code>), or sub-category (<code>subcategory</code>) on update.

      To learn more about <code>reference</code>, use the command:

      <code>/help reference</code>

      To update an item, use the command /e (or /edit ). The pattern is:

      <code>/e {category_abbr} {abbr} {change_what} {the_change}</code>

      For example:

      <code>/e movies drama ai name Artificial Intelligence</code>

      Will update the name of the item with the abbreviation <b>ai</b> to "Artificial Intelligence".

      The fields you can change are: <code>abbr</code>, <code>name</code>, <code>description</code>, <code>reference</code>, and <code>subcategory</code>.

      <b>- Updating selection of items</b>

      Items can be selected and deselected with the command /se (or /select ). The pattern is:

      <code>/se {category_abbr} {sub_category_abbr} {abbr}</code>

      For example:

      <code>/se movies</code>

      Will select every item from the category with abbreviation as <b>movies</b>. If all items are already selected, this command will deselect, instead.

      <code>/se movies drama</code>

      Will select every item from sub-category with abbreviation as <b>drama</b>. If all items are already selected, this command will deselect, instead.

      <code>/se movies drama ai</code>

      Will select the item with abbreviation as <b>ai</b>. If the item is already selected, this command will deselect, instead.

      To learn more about the <code>select</code> attribute, use the command:

      <code>/help select</code>

      Additionaly you can randomly select an item from a category or sub-category with the command /sr (or /selectrandom ). The pattern is:

      <code>/sr {category_abbr} {sub_category_abbr}</code>

      For example:

      <code>/sr movies</code>

      Will select a random item from the category with abbreviation as <b>movies</b>.

      <code>/sr movies drama</code>

      Will select a random item from the sub-category with abbreviation as <b>drama</b>.

      <b>- Archiving items</b>

      Items can be archived with /ar (or /archive ). The pattern is:

      <code>/ar {category_abbr} {sub_category_abbr} {abbr}</code>

      For example:

      <code>/ar movies</code>

      Will archive every item from the category with abbreviation as <b>movies</b>. If all items are already archived, this command will de-archive, instead.

      <code>/ar movies drama</code>

      Will archive every item from sub-category with abbreviation as <b>drama</b>. If all items are already archived, this command will de-archive, instead.

      <code>/ar movies drama ai</code>

      Will archive the item with abbreviation as <b>ai</b>. If the item is already archived, this command will de-archive, instead.

      To learn more about the <code>archive</code> attribute, use the command:

      <code>/help archive</code>

      <b>- Listing items</b>

      To list all items from a category or sub-category, use the command /l (or /list ). The pattern is:

      <code>/l {category_abbr} {sub_category_abbr}</code>

      For example:

      <code>/l movies drama</code>

      Will list all items from the sub-category with the abbreviation as <b>drama</b>.

      To get a list with <code>abbr</code> included, use the command /la (or /listwithabbr ).

      <b>- Removing an item</b>

      To remove an item, use the command /d (or /delete ). The pattern is:

      <code>/d {category_abbr} {sub_category_abbr} {abbr}</code>

      For example:

      <code>/d movies drama ai</code>

      Will remove the item with abbreviation as <b>ai</b>.

      <b>- Information about an item</b>

      To show more information about an item, use the command /s (or /show). The pattern is:

      <code>/s {category_abbr} {sub_category_abbr} {abbr}</code>

      For example:

      <code>/s movies drama ai</code>

      Will show detailed information about the item with abbreviation as <b>ai</b>.
      """
    )
  end

  defp abbr_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>abbr</code> is the field for abbreviations. It is used to identify items, sub-categories, and categories.

      The pattern of an abbreviation is <b>snake_case</b>, this means that every time you perform an input of abbreviation, I will change it to be lowercased and with underline:

      - Movies will become movies

      - MoViEs will become mo_vi_es

      - "I robot" will become i_robot

      After that, if it is a creation or update, I will verify if it has at most 20 characters.
      """
    )
  end

  defp name_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>name</code> is the field responsible to name items, sub-categories, and categories.

      On creation, I will automatically define a name for the element based on the <code>abbr</code>.

      The pattern of a name is <b>Title Case</b>, this means that every time you perform an input of name, I will change it to have the first letter of every word upcased, otherwise downcased:

      - movies will become Movies

      - foods_and_drinks will become "Foods And Drinks"

      - "I, robot" will become "I, Robot"

      A name should have at most 100 characters.
      """
    )
  end

  defp description_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>description</code> is the field that can be used to insert additional information about items, sub-categories, and categories.

      A description should have at most 100 characters.
      """
    )
  end

  defp reference_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>reference</code> is the field that can be used to add links to items.

      If it is a valid link, I will show it as a link when showing items.

      A reference should have at most 100 characters.
      """
    )
  end

  defp archived_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>archived</code> is the field responsible to enable or disable an item.

      An archived item will not be used on random selection operations and will be <s>striked</s> on listings.

      Examples of usage:

      - Define a task as done from a to-do list.

      - Define a movie as watched.
      """
    )
  end

  defp selected_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am here to help!

      <code>selected</code> is the field responsible to select or deselect items.

      A selected item will have a checkmark (<code>[X]</code>) on listings.

      An unselected item will not have a checkmark (<code>[ ]</code>) on listings.

      Examples of usage:

      - Define a task as doing from a to-do list.

      - Define a movie as "watching".
      """
    )
  end
end
