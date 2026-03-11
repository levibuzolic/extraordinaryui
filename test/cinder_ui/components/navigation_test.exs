defmodule CinderUI.Components.NavigationTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Navigation
  alias CinderUI.TestHelpers

  test "breadcrumb link renders" do
    html =
      render_component(&Navigation.breadcrumb_link/1, %{
        href: "/",
        inner_block: TestHelpers.slot("Home")
      })

    assert html =~ "data-slot=\"breadcrumb-link\""
    assert html =~ "Home"
  end

  test "tabs renders active state and ARIA relationships" do
    html =
      render_component(&Navigation.tabs/1, %{
        id: "settings-tabs",
        value: "profile",
        trigger: [
          %{value: "profile", inner_block: fn _, _ -> "Profile" end},
          %{value: "billing", inner_block: fn _, _ -> "Billing" end}
        ],
        content: [
          %{value: "profile", inner_block: fn _, _ -> "Profile Content" end},
          %{value: "billing", inner_block: fn _, _ -> "Billing Content" end}
        ]
      })

    assert html =~ "data-slot=\"tabs\""
    assert html =~ "role=\"tablist\""
    assert html =~ "role=\"tab\""
    assert html =~ "aria-selected=\"true\""
    assert html =~ "aria-controls=\"settings-tabs-panel-profile\""
    assert html =~ "role=\"tabpanel\""
    assert html =~ "aria-labelledby=\"settings-tabs-tab-profile\""
    assert html =~ "Profile Content"
  end

  test "menu renders active and disabled items" do
    html =
      render_component(&Navigation.menu/1, %{
        item: [
          %{href: "#", active: true, inner_block: fn _, _ -> "Overview" end},
          %{href: "#", disabled: true, inner_block: fn _, _ -> "Billing" end}
        ]
      })

    assert html =~ "data-slot=\"menu\""
    assert html =~ "data-slot=\"menu-item\""
    assert html =~ "data-active"
    assert html =~ "aria-disabled=\"true\""
  end

  test "pagination renders navigation structure and active link state" do
    pagination_html =
      render_component(&Navigation.pagination/1, %{
        inner_block: TestHelpers.slot("Pages")
      })

    content_html =
      render_component(&Navigation.pagination_content/1, %{
        inner_block: TestHelpers.slot("Items")
      })

    item_html =
      render_component(&Navigation.pagination_item/1, %{
        inner_block: TestHelpers.slot("Entry")
      })

    link_html =
      render_component(&Navigation.pagination_link/1, %{
        href: "#",
        active: true,
        inner_block: TestHelpers.slot("1")
      })

    previous_html = render_component(&Navigation.pagination_previous/1, %{href: "#"})
    next_html = render_component(&Navigation.pagination_next/1, %{href: "#"})
    ellipsis_html = render_component(&Navigation.pagination_ellipsis/1, %{})

    assert pagination_html =~ "data-slot=\"pagination\""
    assert pagination_html =~ "aria-label=\"pagination\""
    assert content_html =~ "data-slot=\"pagination-content\""
    assert item_html =~ "data-slot=\"pagination-item\""
    assert link_html =~ "data-slot=\"pagination-link\""
    assert link_html =~ "aria-current=\"page\""
    assert previous_html =~ "Go to previous page"
    assert next_html =~ "Go to next page"
    assert ellipsis_html =~ "data-slot=\"pagination-ellipsis\""
  end
end
