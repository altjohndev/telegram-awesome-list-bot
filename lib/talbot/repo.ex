defmodule Talbot.Repo do
  @moduledoc """
  Database integration and helper functions.
  """

  use Ecto.Repo,
    otp_app: :talbot,
    adapter: Ecto.Adapters.Postgres

  @spec maybe_preload(struct() | list(struct()) | nil, any(), keyword()) :: struct() | list(struct()) | nil
  def maybe_preload(schema, preloads, opts \\ []) do
    if Enum.empty?(preloads) do
      schema
    else
      preload(schema, preloads, opts)
    end
  end
end
