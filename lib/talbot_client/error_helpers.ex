defmodule TalbotClient.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building bot error messages.
  """

  require Talbot.Gettext
  alias Talbot.Gettext

  @gettext_domain "client_errors"

  @spec changeset_message(Ecto.Changeset.t()) :: String.t()
  def changeset_message(%{errors: errors}) do
    Enum.reduce(errors, "", &append_changeset_field_message(&2, &1))
  end

  defp append_changeset_field_message(message, {field, errors}) do
    error_message =
      if is_list(errors) do
        errors
        |> Enum.map(&TalbotWeb.ErrorHelpers.translate_error/1)
        |> Enum.join("\n\n")
      else
        TalbotWeb.ErrorHelpers.translate_error(errors)
      end
      |> Recase.to_sentence()

    field_message = Gettext.dgettext(@gettext_domain, "- <code>%{field}</code> errors:", field: field)

    message <> "\n\n" <> field_message <> "\n\n" <> error_message
  end
end
