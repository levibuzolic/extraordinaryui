defmodule CinderUI.Docs.BuildTaskTest do
  use ExUnit.Case, async: false

  @output "tmp/static-docs-test"

  setup do
    File.rm_rf!(@output)
    :ok
  end

  test "build task writes static docs artifacts" do
    Mix.Task.reenable("cinder_ui.docs.build")
    Mix.Task.run("cinder_ui.docs.build", ["--output", @output, "--clean"])

    assert File.exists?(Path.join(@output, "index.html"))
    assert File.exists?(Path.join(@output, "components/actions-button.html"))
    assert File.exists?(Path.join(@output, "components/layout-card.html"))
    assert File.exists?(Path.join(@output, "components/layout-resizable.html"))
    assert File.exists?(Path.join(@output, "components/advanced-carousel.html"))
    assert File.exists?(Path.join(@output, "assets/site.css"))
    assert File.exists?(Path.join(@output, "assets/site.js"))

    index = File.read!(Path.join(@output, "index.html"))
    component_page = File.read!(Path.join(@output, "components/actions-button.html"))
    card_page = File.read!(Path.join(@output, "components/layout-card.html"))
    resizable_page = File.read!(Path.join(@output, "components/layout-resizable.html"))
    carousel_page = File.read!(Path.join(@output, "components/advanced-carousel.html"))

    assert index =~ "Cinder UI"
    assert index =~ "Component Library"
    assert index =~ "GitHub"
    assert index =~ "Hex package"
    assert index =~ "https://hex.pm/packages/cinder_ui"
    refute index =~ "href=\"../index.html\""
    assert index =~ "Actions.button"
    assert index =~ "Copy HEEx"
    assert index =~ "Open docs"
    assert index =~ "./components/actions-button.html"

    assert index =~
             "<a href=\"./components/actions-button.html\" class=\"hover:underline underline-offset-4\">"

    assert index =~ "data-copy-template="
    assert index =~ "Phoenix template (HEEx)"
    assert index =~ ~s(id="code-actions-button")
    assert index =~ "data-theme-mode"
    assert index =~ "theme-color"
    assert index =~ "theme-radius"
    assert index =~ "data-slot=\"native-select-wrapper\""
    assert index =~ "data-slot=\"native-select\""
    assert index =~ ~s(href="./index.html")
    assert index =~ ~s(aria-current="page")
    assert index =~ "sidebar-link"

    assert component_page =~ "Original shadcn/ui docs"
    assert component_page =~ "Usage (HEEx)"

    assert component_page =~ "Attributes"
    assert component_page =~ "Slots"

    assert component_page =~ "https://ui.shadcn.com/docs/components/button"
    assert component_page =~ "<code>variant</code>"
    refute component_page =~ "Function Docs"
    refute component_page =~ "docs-markdown"
    assert component_page =~ ~s(href="../components/actions-button.html")
    assert component_page =~ ~s(aria-current="page")
    assert component_page =~ "Primary CTA"
    assert component_page =~ "Destructive Loading"
    refute component_page =~ "Inline Docs Examples"
    refute component_page =~ "Outline small action"
    refute component_page =~ "Loading destructive action"
    refute component_page =~ "## Attributes"

    assert card_page =~ "Profile Card"
    assert card_page =~ "Pricing Card"
    assert card_page =~ "&lt;.card_header&gt;"
    assert card_page =~ "Usage (HEEx)"

    assert resizable_page =~ "<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>"
    assert resizable_page =~ "<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>"

    refute resizable_page =~
             "&amp;lt;div class=&amp;quot;rounded-md bg-muted p-2 text-xs&amp;quot;&amp;gt;Panel A&amp;lt;/div&amp;gt;"

    assert carousel_page =~ "<div class=\"h-24 rounded-md bg-muted\"></div>"
    assert carousel_page =~ "<div class=\"h-24 rounded-md bg-muted/60\"></div>"

    refute carousel_page =~
             "&amp;lt;div class=&amp;quot;h-24 rounded-md bg-muted&amp;quot;&amp;gt;&amp;lt;/div&amp;gt;"

    site_js = File.read!(Path.join(@output, "assets/site.js"))
    assert site_js =~ "themedTokenKeys"
    assert site_js =~ "removeProperty"
    refute site_js =~ "highlightCodeBlocks"
    refute site_js =~ "tok-tag"

    site_css = File.read!(Path.join(@output, "assets/site.css"))
    assert site_css =~ ".docs-markdown"
    assert site_css =~ "summary:not([data-slot])::after"
    assert site_css =~ "summary::marker"
    refute site_css =~ ".code-highlight .tok-tag"
  end
end
