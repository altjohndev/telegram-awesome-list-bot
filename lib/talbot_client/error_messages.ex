defmodule TalbotClient.ErrorMessages do
  @moduledoc """
  Utility to convert error atoms into messages
  """

  require Talbot.Gettext
  alias Talbot.Gettext

  @gettext_domain "client_errors"

  @spec get(atom()) :: String.t()
  def get(:category_not_found) do
    Gettext.dgettext(@gettext_domain, "Sorry, I did not found your category.")
  end

  def get(:failed_to_archive_item) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not archive this item.")
  end

  def get(:failed_to_create_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not create this category.")
  end

  def get(:failed_to_create_sub_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not create this sub-category.")
  end

  def get(:failed_to_create_item) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not create this item.")
  end

  def get(:failed_to_delete_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not delete this category.")
  end

  def get(:failed_to_delete_sub_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not delete this sub-category.")
  end

  def get(:failed_to_delete_item) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not delete this item.")
  end

  def get(:failed_to_select_item) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not select this item.")
  end

  def get(:failed_to_update_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not update this category.")
  end

  def get(:failed_to_update_sub_category) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not update this sub-category.")
  end

  def get(:failed_to_update_item) do
    Gettext.dgettext(@gettext_domain, "Sorry, I can not update this item.")
  end

  def get(:invalid_archive_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/ar {category_abbr}</code>

      <code>/ar {category_abbr} {sub_category_abbr}</code>

      <code>/ar {category_abbr} . {item_abbr}</code>

      <code>/ar {category_abbr} {sub_category_abbr} {item_abbr}</code>
      """
    )
  end

  def get(:invalid_delete_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/d {category_abbr}</code>

      <code>/d {category_abbr} {sub_category_abbr}</code>

      <code>/d {category_abbr} . {item_abbr}</code>

      <code>/d {category_abbr} {sub_category_abbr} {item_abbr}</code>
      """
    )
  end

  def get(:invalid_edit_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/e {category_abbr} {field} {value}</code>

      <code>/e {category_abbr} {sub_category_abbr} {field} {value}</code>

      <code>/e {category_abbr} . {item_abbr} {field} {value}</code>

      <code>/e {category_abbr} {sub_category_abbr} {item_abbr} {field} {value}</code>
      """
    )
  end

  def get(:invalid_locale_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/locale en_US</code>

      <code>/locale pt_BR</code>
      """
    )
  end

  def get(:invalid_new_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/n {category_abbr}</code>

      <code>/n {category_abbr} {sub_category_abbr}</code>

      <code>/n {category_abbr} . {item_abbr}</code>

      <code>/n {category_abbr} {sub_category_abbr} {item_abbr}</code>
      """
    )
  end

  def get(:invalid_random_select_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/sr {category_abbr}</code>

      <code>/sr {category_abbr} {sub_category_abbr}</code>

      <code>/sr {category_abbr} .</code>
      """
    )
  end

  def get(:invalid_select_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/se {category_abbr}</code>

      <code>/se {category_abbr} {sub_category_abbr}</code>

      <code>/se {category_abbr} . {item_abbr}</code>

      <code>/se {category_abbr} {sub_category_abbr} {item_abbr}</code>
      """
    )
  end

  def get(:invalid_show_input) do
    Gettext.dgettext(
      @gettext_domain,
      """
      Sorry, your input is invalid.

      Usage:

      <code>/s {category_abbr}</code>

      <code>/s {category_abbr} {sub_category_abbr}</code>

      <code>/s {category_abbr} . {item_abbr}</code>

      <code>/s {category_abbr} {sub_category_abbr} {item_abbr}</code>
      """
    )
  end

  def get(:item_not_found) do
    Gettext.dgettext(@gettext_domain, "Sorry, I did not found your item.")
  end

  def get(:locale_already_set) do
    Gettext.dgettext(@gettext_domain, "I am already speaking this language.")
  end

  def get(:sub_category_not_found) do
    Gettext.dgettext(@gettext_domain, "Sorry, I did not found your sub-category.")
  end

  def get(:unknown_command) do
    Gettext.dgettext(@gettext_domain, "Sorry, I do not recognize this command.")
  end

  def get(_error) do
    # :failed_to_fetch_chat
    # :failed_to_identify_command
    # :failed_to_identify_from_name
    # :failed_to_identify_message_id
    # :failed_to_parse_command
    # :failed_to_send_message
    # :failed_to_update_chat_passcode
    # :failed_to_update_locale
    # :raised_exception
    # :unknown_update_type
    Gettext.dgettext(@gettext_domain, "Oops... I had some problems with your request.")
  end
end
