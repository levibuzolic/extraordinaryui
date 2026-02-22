defmodule ExtraordinaryUI.Docs.BuildTaskTest do
  use ExUnit.Case, async: false

  @output "tmp/static-docs-test"

  setup do
    File.rm_rf!(@output)
    :ok
  end

  test "build task writes static docs artifacts" do
    Mix.Task.reenable("extraordinary_ui.docs.build")
    Mix.Task.run("extraordinary_ui.docs.build", ["--output", @output, "--clean"])

    assert File.exists?(Path.join(@output, "index.html"))
    assert File.exists?(Path.join(@output, "assets/site.css"))
    assert File.exists?(Path.join(@output, "assets/site.js"))

    index = File.read!(Path.join(@output, "index.html"))

    assert index =~ "Extraordinary UI"
    assert index =~ "Component Library"
    assert index =~ "Actions.button/1"
    assert index =~ "Phoenix template (HEEx)"
    assert index =~ "data-theme-mode"
    assert index =~ "theme-color"
    assert index =~ "theme-radius"

    site_js = File.read!(Path.join(@output, "assets/site.js"))
    assert site_js =~ "themedTokenKeys"
    assert site_js =~ "removeProperty"
  end
end
