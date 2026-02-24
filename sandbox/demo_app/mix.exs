defmodule DemoApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :demo_app,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DemoApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", shared_dev_lib_path(), "test/support"]
  defp elixirc_paths(_), do: ["lib", shared_dev_lib_path()]

  defp shared_dev_lib_path do
    Path.expand("../../dev/lib", __DIR__)
  end

  # Creates deps/cinder_ui as a symlink to the local path dep so Tailwind's
  # @source "../../deps/cinder_ui" directive (added by mix cinder_ui.install)
  # works the same way it would for a real hex consumer.
  defp link_cinder_ui_dep(_args) do
    File.mkdir_p!("deps")

    case File.ln_s("../../..", "deps/cinder_ui") do
      :ok ->
        Mix.shell().info("Created deps/cinder_ui symlink for local development")

      {:error, :eexist} ->
        :ok

      {:error, reason} ->
        Mix.shell().error("Could not create deps/cinder_ui symlink: #{inspect(reason)}")
    end
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.3"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0"},
      {:lucide_icons, "~> 2.0"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:cinder_ui, path: "../.."}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", &link_cinder_ui_dep/1, "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind demo_app", "esbuild demo_app"],
      "assets.deploy": [
        "tailwind demo_app --minify",
        "esbuild demo_app --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
