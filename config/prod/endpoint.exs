import Config

config :talbot, TalbotWeb.Endpoint,
  cache_static_manifest: Path.expand("../../priv/static/cache_manifest.json", __DIR__),
  server: true,
  force_ssl: [rewrite_on: [:x_forwarded_proto], host: nil]
