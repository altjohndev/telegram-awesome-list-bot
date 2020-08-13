import Config

config :talbot, Talbot.Repo,
  username: "talbot",
  password: "talbot",
  database: "talbot_dev",
  hostname: System.get_env("TALBOT__POSTGRES_HOSTNAME", "postgres"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
