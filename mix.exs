defmodule CinderUI.MixProject do
  use Mix.Project

  @source_url "https://github.com/levi/cinder-ui"
  @version "0.1.0"

  def project do
    [
      app: :cinder_ui,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      aliases: aliases(),
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls, summary: [threshold: 90]]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: ["test.all": :test]
    ]
  end

  defp preferred_cli_env do
    [
      "test.all": :test,
      quality: :test,
      credo: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.github": :test,
      "coveralls.html": :test,
      "coveralls.json": :test,
      "coveralls.lcov": :test,
      "coveralls.cobertura": :test,
      "coveralls.xml": :test
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7 or ~> 1.8"},
      {:phoenix_live_view, "~> 1.0"},
      {:earmark, "~> 1.4", runtime: false},
      {:lucide_icons, "~> 2.0", optional: true},
      {:phoenix_storybook, "~> 0.9.3", optional: true},
      {:jason, "~> 1.4", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:floki, ">= 0.35.0", only: :test}
    ]
  end

  defp aliases do
    [
      "test.all": ["test"],
      quality: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "cmd env MIX_ENV=test mix coveralls --raise"
      ]
    ]
  end

  defp description do
    "Shadcn-inspired Tailwind component library for Phoenix applications with installer tooling and Storybook previews."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      maintainers: ["Levi"],
      files: [
        "lib/cinder_ui.ex",
        "lib/cinder_ui/classes.ex",
        "lib/cinder_ui/components",
        "lib/cinder_ui/hooks.ex",
        "lib/cinder_ui/icons.ex",
        "lib/cinder_ui/storybook.ex",
        "lib/mix/tasks/cinder_ui.install.ex",
        "priv",
        "assets",
        "mix.exs",
        "README.md",
        "CONTRIBUTING.md",
        "THIRD_PARTY_NOTICES.md",
        "CHANGELOG.md",
        "LICENSE",
        "PROGRESS.md"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CONTRIBUTING.md",
        "THIRD_PARTY_NOTICES.md",
        "PROGRESS.md",
        "CHANGELOG.md"
      ],
      groups_for_modules: [
        Core: [CinderUI, CinderUI.Classes, CinderUI.Hooks, CinderUI.Icons],
        Components: [
          CinderUI.Components,
          CinderUI.Components.Advanced,
          CinderUI.Components.Actions,
          CinderUI.Components.DataDisplay,
          CinderUI.Components.Feedback,
          CinderUI.Components.Forms,
          CinderUI.Components.Layout,
          CinderUI.Components.Navigation,
          CinderUI.Components.Overlay
        ],
        Storybook: [CinderUI.Storybook],
        "Mix Tasks": [Mix.Tasks.CinderUi.Install]
      ]
    ]
  end
end
