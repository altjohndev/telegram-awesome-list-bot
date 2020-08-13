import Config

config :talbot, TalbotWeb.Endpoint,
  live_view: [signing_salt: "2H9pqSFy"],
  pubsub_server: Talbot.PubSub,
  url: [host: "localhost"],
  render_errors: [view: TalbotWeb.ErrorView, accepts: ~w(html json), layout: false],
  secret_key_base: "86XlX5ocVV0LTfnOLTTvLlGzPS5ZL4zFnGEpuV8qCmIhF+bYptdbNnVQX5lS8/ju"
