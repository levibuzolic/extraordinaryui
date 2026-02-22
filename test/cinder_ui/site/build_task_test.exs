defmodule CinderUI.Site.BuildTaskTest do
  use ExUnit.Case, async: false

  @output "tmp/static-site-test"

  setup do
    File.rm_rf!(@output)
    :ok
  end

  test "build task writes landing site and bundled docs" do
    Mix.Task.reenable("cinder_ui.site.build")
    Mix.Task.run("cinder_ui.site.build", ["--output", @output, "--clean"])

    assert File.exists?(Path.join(@output, "index.html"))
    assert File.exists?(Path.join(@output, ".nojekyll"))
    assert File.exists?(Path.join(@output, "assets/site.css"))
    assert File.exists?(Path.join(@output, "docs/index.html"))
    assert File.exists?(Path.join(@output, "docs/components/actions-button.html"))

    index = File.read!(Path.join(@output, "index.html"))

    assert index =~ "Cinder UI"
    assert index =~ "Browse Component Library"
    assert index =~ "./docs/index.html"
    assert index =~ "https://hexdocs.pm/cinder_ui"
    assert index =~ "GitHub repository"
    assert index =~ "Component examples on the homepage"
    assert index =~ "Actions.button_group"
    assert index =~ "Forms.field"
    assert index =~ "Navigation.tabs"
    assert index =~ "Add dependencies to <code>mix.exs</code>"
    assert index =~ "Run in terminal"

    assert index =~ "{:lucide_icons, \"~> 2.0\"} # optional, recommended for <.icon />"

    assert index =~ "mix cinder_ui.install --skip-existing"
    assert index =~ "Drop-in for existing Phoenix + LiveView projects."
    assert index =~ "Phoenix-native API"
    assert index =~ "Fast app integration"
    assert index =~ "Component reference"
    refute index =~ "Static docs export"
    assert index =~ "https://ui.shadcn.com/docs"
    assert index =~ "style-nova"
    assert index =~ "shadcn/ui reference"
    assert index =~ "data-site-theme"
    assert index =~ "cinder_ui:site:theme"
    assert index =~ "highlightCodeBlocks"
    assert index =~ "Switch to dark mode"
    assert index =~ "Switch to light mode"

    docs_index = File.read!(Path.join(@output, "docs/index.html"))
    assert docs_index =~ "Component Library"

    site_css = File.read!(Path.join(@output, "assets/site.css"))
    assert site_css =~ ".code-highlight .tok-tag"
  end
end
