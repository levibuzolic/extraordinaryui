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
    assert File.exists?(Path.join(@output, "components/actions-button.html"))
    assert File.exists?(Path.join(@output, "assets/site.css"))
    assert File.exists?(Path.join(@output, "assets/site.js"))

    index = File.read!(Path.join(@output, "index.html"))
    component_page = File.read!(Path.join(@output, "components/actions-button.html"))

    assert index =~ "Extraordinary UI"
    assert index =~ "Component Library"
    assert index =~ "Actions.button/1"
    assert index =~ "Copy HEEx"
    assert index =~ "Open docs"
    assert index =~ "./components/actions-button.html"
    assert index =~ "data-copy-template="
    assert index =~ "Phoenix template (HEEx)"
    assert index =~ ~s(id="code-actions-button")
    assert index =~ "data-theme-mode"
    assert index =~ "theme-color"
    assert index =~ "theme-radius"
    assert index =~ ~s(href="./index.html")
    assert index =~ ~s(aria-current="page")
    assert index =~ "sidebar-link"

    assert component_page =~ "Original shadcn/ui docs"
    assert component_page =~ "Usage (HEEx)"

    assert component_page =~
             "Attributes (Generated from <code class=\"inline-code\">attr</code> definitions)"

    assert component_page =~
             "Slots (Generated from <code class=\"inline-code\">slot</code> definitions)"

    assert component_page =~ "https://ui.shadcn.com/docs/components/button"
    assert component_page =~ "<code>variant</code>"
    assert component_page =~ "class=\"inline-code\">attr</code>"
    assert component_page =~ "docs-markdown"
    assert component_page =~ "<h2>Attributes</h2>"
    assert component_page =~ "<ul>"
    assert component_page =~ ~s(href="../components/actions-button.html")
    assert component_page =~ ~s(aria-current="page")
    refute component_page =~ "## Attributes"

    site_js = File.read!(Path.join(@output, "assets/site.js"))
    assert site_js =~ "themedTokenKeys"
    assert site_js =~ "removeProperty"

    site_css = File.read!(Path.join(@output, "assets/site.css"))
    assert site_css =~ ".docs-markdown"
  end
end
