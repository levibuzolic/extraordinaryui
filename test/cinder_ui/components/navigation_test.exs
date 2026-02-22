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

  test "tabs renders active state" do
    html =
      render_component(&Navigation.tabs/1, %{
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
end
