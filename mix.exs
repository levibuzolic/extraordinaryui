defmodule ExtraordinaryUI.MixProject do
  use Mix.Project

  @source_url "https://github.com/levi/extraordinaryui"
  @version "0.1.0"

  def project do
    [
      app: :extraordinary_ui,
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
        "lib",
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
        Core: [ExtraordinaryUI, ExtraordinaryUI.Classes, ExtraordinaryUI.Hooks],
        "Static Docs": [ExtraordinaryUI.Docs.Catalog, Mix.Tasks.ExtraordinaryUi.Docs.Build],
        Components: [
          ExtraordinaryUI.Components,
          ExtraordinaryUI.Components.Advanced,
          ExtraordinaryUI.Components.Actions,
          ExtraordinaryUI.Components.DataDisplay,
          ExtraordinaryUI.Components.Feedback,
          ExtraordinaryUI.Components.Forms,
          ExtraordinaryUI.Components.Layout,
          ExtraordinaryUI.Components.Navigation,
          ExtraordinaryUI.Components.Overlay
        ],
        Storybook: [ExtraordinaryUI.Storybook],
        "Mix Tasks": [
          Mix.Tasks.ExtraordinaryUi.Install,
          Mix.Tasks.ExtraordinaryUi.Docs.Build,
          Mix.Tasks.ExtraordinaryUi.Site.Build
        ]
      ]
    ]
  end
end
