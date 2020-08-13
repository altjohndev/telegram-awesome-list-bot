defmodule TalbotWeb.ErrorView do
  @moduledoc """
  View for errors.
  """

  use TalbotWeb, :view

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
