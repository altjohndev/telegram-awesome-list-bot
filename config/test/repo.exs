import Config

config :talbot, Talbot.Repo,
  username: "talbot",
  password: "talbot",
  database: "talbot_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: System.get_env("TALBOT__POSTGRES_HOSTNAME", "postgres"),
  pool: Ecto.Adapters.SQL.Sandbox
