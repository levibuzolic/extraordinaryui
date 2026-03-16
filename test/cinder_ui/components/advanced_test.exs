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

  test "carousel renders aria semantics, controls, and indicators" do
    html =
      render_component(&Advanced.carousel/1, %{
        id: "feature-carousel",
        autoplay: 4000,
        indicators: true,
        item: [
          %{inner_block: fn _, _ -> "Slide one" end},
          %{inner_block: fn _, _ -> "Slide two" end}
        ]
      })

    assert html =~ "data-slot=\"carousel\""
    assert html =~ "data-autoplay=\"4000\""
    assert html =~ ~s(aria-roledescription="carousel")
    assert html =~ ~s(data-slot="carousel-item")
    assert html =~ ~s(aria-roledescription="slide")
    assert html =~ ~s(aria-label="Previous slide")
    assert html =~ ~s(aria-label="Next slide")
    assert html =~ ~s(data-slot="carousel-indicator")
    assert html =~ ~s(aria-label="Go to slide 1")
    assert html =~ "Slide one"
    assert html =~ "Slide two"
  end

  test "sidebar layout renders panel and main regions with sidebar tokens" do
    layout_html =
      render_component(&Advanced.sidebar_layout/1, %{
        id: "shell",
        header: [%{inner_block: fn _, _ -> "Header" end}],
        sidebar: [%{inner_block: fn _, _ -> "Overview" end}],
        footer: [%{inner_block: fn _, _ -> "Footer" end}],
        main: [
          %{
            class: "px-8",
            inner_block: fn _, _ -> "Main content" end
          }
        ]
      })

    assert layout_html =~ "data-slot=\"sidebar-layout\""
    assert layout_html =~ "data-slot=\"sidebar-panel\""
    assert layout_html =~ "data-slot=\"sidebar-content\""
    assert layout_html =~ "data-slot=\"sidebar-main\""
    assert layout_html =~ "Header"
    assert layout_html =~ "Footer"
    assert layout_html =~ "bg-sidebar"
    assert layout_html =~ "text-sidebar-foreground"
    assert layout_html =~ "border-sidebar-border"
    assert layout_html =~ "px-8"
  end

  test "combobox renders hook-backed input and items" do
    html =
      render_component(&Advanced.combobox/1, %{
        id: "plan-combobox",
        value: "Pro",
        option: [
          %{value: "Free", label: "Free", inner_block: fn -> "" end},
          %{value: "Pro", label: "Pro", inner_block: fn -> "" end}
        ]
      })

    assert html =~ "data-slot=\"combobox\""
    assert html =~ "phx-hook=\"CuiCombobox\""
    assert html =~ "data-slot=\"combobox-input\""
    assert html =~ "data-slot=\"combobox-item\""
    assert html =~ "data-slot=\"select-check\""
  end

  test "chart renders title, description, and content shell" do
    html =
      render_component(&Advanced.chart/1, %{
        title: [%{inner_block: fn _, _ -> "Traffic" end}],
        description: [%{inner_block: fn _, _ -> "Last 7 days" end}],
        inner_block: [%{inner_block: fn _, _ -> "<div>Chart body</div>" end}]
      })

    assert html =~ "data-slot=\"chart\""
    assert html =~ "data-slot=\"chart-content\""
    assert html =~ "Traffic"
    assert html =~ "Last 7 days"
  end
end
