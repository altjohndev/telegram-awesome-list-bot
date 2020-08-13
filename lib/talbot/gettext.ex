defmodule Talbot.Gettext do
  @moduledoc """
  A module providing internationalization with a gettext-based API.
  """

  use Gettext, otp_app: :talbot

  @spec known_locales :: list(String.t())
  def known_locales do
    Gettext.known_locales(Talbot.Gettext)
  end

  @spec update_locale(String.t()) :: :ok
  def update_locale(locale) do
    if locale in known_locales() do
      Gettext.put_locale(Talbot.Gettext, locale)
    end

    :ok
  end
end
