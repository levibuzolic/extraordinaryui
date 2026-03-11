defmodule CinderUI.Components.AdvancedTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Advanced

  test "command renders groups" do
    html =
      render_component(&Advanced.command/1, %{
        group: [
          %{heading: "Main", inner_block: fn _, _ -> "Items" end}
        ]
      })

    assert html =~ "data-slot=\"command\""
    assert html =~ "Main"
  end

  test "carousel renders aria semantics and controls" do
    html =
      render_component(&Advanced.carousel/1, %{
        id: "feature-carousel",
        item: [
          %{inner_block: fn _, _ -> "Slide one" end},
          %{inner_block: fn _, _ -> "Slide two" end}
        ]
      })

    assert html =~ "data-slot=\"carousel\""
    assert html =~ ~s(aria-roledescription="carousel")
    assert html =~ ~s(data-slot="carousel-item")
    assert html =~ ~s(aria-roledescription="slide")
    assert html =~ ~s(aria-label="Previous slide")
    assert html =~ ~s(aria-label="Next slide")
    assert html =~ "Slide one"
    assert html =~ "Slide two"
  end

  test "sidebar uses sidebar token classes" do
    html =
      render_component(&Advanced.sidebar/1, %{
        rail: [%{inner_block: fn _, _ -> "Overview" end}],
        inset: [%{inner_block: fn _, _ -> "Main content" end}]
      })

    assert html =~ "data-slot=\"sidebar\""
    assert html =~ "data-slot=\"sidebar-rail\""
    assert html =~ "bg-sidebar"
    assert html =~ "text-sidebar-foreground"
    assert html =~ "border-sidebar-border"
  end
end
