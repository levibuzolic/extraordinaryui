defmodule CinderUI.Docs.BuildTaskTest do
  use ExUnit.Case, async: false

  @output "dist/site"

  setup do
    File.rm_rf!(@output)
    :ok
  end

  test "build task writes unified static site and docs artifacts" do
    Mix.Task.reenable("cinder_ui.docs.build")
    Mix.Task.run("cinder_ui.docs.build", [])

    assert File.exists?(Path.join(@output, "index.html"))
    assert File.exists?(Path.join(@output, ".nojekyll"))
    assert File.exists?(Path.join(@output, "docs/index.html"))
    assert File.exists?(Path.join(@output, "docs/components/actions-button.html"))
    assert File.exists?(Path.join(@output, "docs/components/layout-card.html"))
    assert File.exists?(Path.join(@output, "docs/assets/site.css"))
    assert File.exists?(Path.join(@output, "docs/assets/site.js"))

    marketing_index = File.read!(Path.join(@output, "index.html"))
    docs_index = File.read!(Path.join(@output, "docs/index.html"))
    component_page = File.read!(Path.join(@output, "docs/components/actions-button.html"))
    site_js = File.read!(Path.join(@output, "docs/assets/site.js"))
    site_css = File.read!(Path.join(@output, "docs/assets/site.css"))

    assert marketing_index =~ "Cinder UI"
    assert marketing_index =~ "Browse Component Library"
    assert marketing_index =~ "./docs/index.html"
    assert marketing_index =~ "https://hexdocs.pm/cinder_ui"
    assert marketing_index =~ "GitHub repository"
    assert marketing_index =~ "Component examples"

    assert docs_index =~ "Component Library"
    assert docs_index =~ "Actions.button"
    assert docs_index =~ "Open docs"
    assert docs_index =~ "./components/actions-button.html"
    assert docs_index =~ ~s(href="../index.html")

    assert component_page =~ "Original shadcn/ui docs"
    assert component_page =~ "Attributes"
    assert component_page =~ "Slots"
    assert component_page =~ "https://ui.shadcn.com/docs/components/button"
    assert component_page =~ ~s(data-slot="component-preview")

    assert site_js =~ "highlightCodeBlocks"
    assert site_js =~ "initCommandPalette"
    assert site_js =~ "restoreSidebarScroll"
    assert site_css =~ ".docs-markdown"
    assert site_css =~ ".docs-k-panel"
  end

  test "build task rejects flags and options" do
    assert_raise Mix.Error, fn ->
      Mix.Task.reenable("cinder_ui.docs.build")
      Mix.Task.run("cinder_ui.docs.build", ["--clean"])
    end
  end
end
