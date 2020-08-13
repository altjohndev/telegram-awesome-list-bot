defmodule TalbotClient.Commands.Start do
  @moduledoc """
  Command to fetch the chat and reply with a welcome message.
  """

  use TalbotClient.Pipeline

  @gettext_domain "client_help"

  @spec handle_message(Pipeline.t()) :: Pipeline.t()
  def handle_message(pipeline) do
    append_message(pipeline, &build_message/1)
  end

  defp build_message(_pipeline) do
    dgettext(
      @gettext_domain,
      """
      I am ready!

      Start by creating a category with the /n command.

      For example:

      <code>/n movies</code>

      <code>/n FoodsAndDrinks</code>

      Then, create a sub-category.

      For example:

      <code>/n movies drama</code>

      <code>/n foods_and_drinks desserts</code>

      Finally, create an item.

      For example:

      <code>/n movies drama ai</code>

      <code>/n movies . fight club</code>

      <code>/n foods_and_drinks desserts ice cream</code>

      <code>/n foods_and_drinks . pizza</code>

      For more information about commands, please use the /help command.
      """
    )
  end
end
