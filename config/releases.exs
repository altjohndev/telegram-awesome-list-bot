import Config

defmodule Talbot.Releases.Helper do
  def endpoint_settings do
    port = get_env("PORT", :integer, 80)

    settings = [
      check_origin: get_env("ORIGIN_HOSTNAMES", :list, []),
      http: [
        port: port,
        transport_options: [socket_opts: [:inet6]]
      ],
      secret_key_base: get_env!("SECRET_KEY_BASE"),
      url: [
        host: get_env!("HOSTNAME"),
        port: port
      ]
    ]

    if get_env("HTTPS", :boolean, true) do
      https_settings =
        case get_env("CACERTFILE_PATH", nil) do
          nil -> []
          cacertfile -> [cacertfile: cacertfile]
        end

      Keyword.merge(settings,
        https:
          Keyword.merge(https_settings,
            cipher_suite: :strong,
            certfile: get_env!("CERTFILE_PATH"),
            keyfile: get_env!("KEYFILE_PATH"),
            otp_app: :talbot,
            port: 443
          )
      )
    else
      settings
    end
  end

  def nadia_settings do
    [
      token: get_env!("TELEGRAM_BOT_TOKEN")
    ]
  end

  def repo_settings do
    settings = [
      pool_size: get_env("DATABASE_POOL_SIZE", :integer, 10),
      ssl: get_env("DATABASE_SSL", :boolean, false)
    ]

    case get_env("DATABASE_URL", nil) do
      nil ->
        Keyword.merge(settings,
          database: get_env("DATABASE_NAME", "talbot"),
          hostname: get_env("DATABASE_HOSTNAME", "postgres"),
          password: get_env("DATABASE_PASSWORD", "talbot"),
          username: get_env("DATABASE_USERNAME", "talbot")
        )

      url ->
        Keyword.merge(settings, url: url)
    end
  end

  def talbot_settings do
    [
      bot_name: get_env("BOT_NAME", "awesome_list_bot")
    ]
  end

  defp get_env(name, type \\ :string, default) do
    env_name = "TALBOT__#{name}"

    case {System.get_env(env_name), type} do
      {nil, _type} -> default
      {value, :atom} -> String.to_atom(value)
      {value, :boolean} -> String.to_existing_atom(value)
      {value, :integer} -> String.to_integer(value)
      {value, :list} -> String.split(value, ",")
      {value, :string} -> value
    end
  end

  defp get_env!(env_name, type \\ :string) do
    case get_env(env_name, type, nil) do
      nil -> raise "environment variable #{env_name} is missing"
      value -> value
    end
  end
end

alias Talbot.Releases.Helper

config :nadia, Helper.nadia_settings()
config :talbot, TalbotWeb.Endpoint, Helper.endpoint_settings()
config :talbot, Talbot.Repo, Helper.repo_settings()
config :talbot, Helper.talbot_settings()
