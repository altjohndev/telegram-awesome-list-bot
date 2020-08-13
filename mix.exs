defmodule Talbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :talbot,
      version: "0.0.1",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      default_release: :talbot,
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      mod: {Talbot.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      i18n: ["i18n.extract", "i18n.merge.en_US", "i18n.merge.pt_BR"],
      "i18n.extract": ["gettext.extract"],
      "i18n.merge.en_US": ["gettext.merge priv/gettext --locale en_US"],
      "i18n.merge.pt_BR": ["gettext.merge priv/gettext --locale pt_BR"],
      setup: ["update.deps", "ecto.setup"],
      start: ["phx.server"],
      test: ["ecto.setup", "test"],
      "test.all": ["test.static", "test.coverage"],
      "test.coverage": ["coveralls"],
      "test.static": ["format --check-formatted", "credo list --all"],
      "update.deps": ["deps.get", "cmd yarn install --cwd assets"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.4.0", only: :test, runtime: false},
      {:ecto_sql, "~> 3.4.5"},
      {:excoveralls, "~> 0.13.1", only: :test},
      {:floki, "~> 0.27.0", only: :test},
      {:gettext, "~> 0.18.1"},
      {:jason, "~> 1.2.1"},
      {:nadia, "~> 0.7.0"},
      {:phoenix_ecto, "~> 4.1.0"},
      {:phoenix_html, "~> 2.14.2"},
      {:phoenix_live_dashboard, "~> 0.2.7"},
      {:phoenix_live_reload, "~> 1.2.4", only: :dev},
      {:phoenix_live_view, "~> 0.14.4"},
      {:phoenix, "~> 1.5.4"},
      {:plug_cowboy, "~> 2.3.0"},
      {:postgrex, "~> 0.15.5"},
      {:recase, "~> 0.6.0"},
      {:telemetry_metrics, "~> 0.5.0"},
      {:telemetry_poller, "~> 0.5.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp preferred_cli_env do
    [
      credo: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test,
      "coveralls.post": :test,
      test: :test,
      "test.all": :test,
      "test.coverage": :test,
      "test.static": :test
    ]
  end

  defp releases do
    [
      talbot: [
        include_erts: false,
        include_executables_for: [:unix]
      ]
    ]
  end
end
