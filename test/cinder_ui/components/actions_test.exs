defmodule CinderUI.Components.ActionsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Actions
  alias CinderUI.TestHelpers

  test "button renders default classes" do
    html = render_component(&Actions.button/1, %{inner_block: TestHelpers.slot("Save")})
    assert TestHelpers.attr(html, "[data-slot='button']", "data-slot") == "button"
    assert TestHelpers.text(html, "[data-slot='button']") == "Save"
  end

  test "toggle renders pressed state" do
    html =
      render_component(&Actions.toggle/1, %{pressed: true, inner_block: TestHelpers.slot("Bold")})

    assert TestHelpers.attr(html, "[data-slot='toggle']", "data-state") == "on"
    assert TestHelpers.text(html, "[data-slot='toggle']") == "Bold"
  end

  test "button_group applies merged-border classes" do
    html =
      render_component(&Actions.button_group/1, %{
        inner_block: [
          %{inner_block: fn _, _ -> "One" end},
          %{inner_block: fn _, _ -> "Two" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='button-group']", "data-slot") == "button-group"
    assert TestHelpers.text(html, "[data-slot='button-group']") == "OneTwo"
  end

  test "toggle_group renders type and orientation metadata" do
    html =
      render_component(&Actions.toggle_group/1, %{
        type: :multiple,
        orientation: :vertical,
        inner_block: TestHelpers.slot("Items")
      })

    assert TestHelpers.attr(html, "[data-slot='toggle-group']", "data-type") == "multiple"
    assert TestHelpers.attr(html, "[data-slot='toggle-group']", "data-orientation") == "vertical"
    assert TestHelpers.attr(html, "[data-slot='toggle-group']", "role") == "group"
  end
end
