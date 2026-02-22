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
    assert index =~ "Actions.button_group/1"
    assert index =~ "Forms.field/1"
    assert index =~ "Navigation.tabs/1"
    assert index =~ "https://ui.shadcn.com/docs"
    assert index =~ "style-nova"
    assert index =~ "shadcn/ui reference"
    assert index =~ "data-site-theme"
    assert index =~ "cinder_ui:site:theme"
    assert index =~ "Switch to dark mode"
    assert index =~ "Switch to light mode"

    docs_index = File.read!(Path.join(@output, "docs/index.html"))
    assert docs_index =~ "Component Library"
  end
end
