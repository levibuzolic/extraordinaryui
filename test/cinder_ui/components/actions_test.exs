defmodule CinderUI.Components.ActionsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Actions
  alias CinderUI.TestHelpers

  test "button renders default classes" do
    html = render_component(&Actions.button/1, %{inner_block: TestHelpers.slot("Save")})
    assert html =~ "data-slot=\"button\""
    assert html =~ "Save"
  end

  test "toggle renders pressed state" do
    html =
      render_component(&Actions.toggle/1, %{pressed: true, inner_block: TestHelpers.slot("Bold")})

    assert html =~ "data-state=\"on\""
    assert html =~ "Bold"
  end

  test "button_group applies merged-border classes" do
    html =
      render_component(&Actions.button_group/1, %{
        inner_block: [
          %{inner_block: fn _, _ -> "One" end},
          %{inner_block: fn _, _ -> "Two" end}
        ]
      })

    assert html =~ "data-slot=\"button-group\""
    assert html =~ "[&amp;&gt;*:not(:first-child)]:-ml-px"
    assert html =~ "[&amp;&gt;*:first-child]:rounded-r-none"
    assert html =~ "[&amp;&gt;*:last-child]:rounded-l-none"
  end

  test "toggle_group renders type and orientation metadata" do
    html =
      render_component(&Actions.toggle_group/1, %{
        type: :multiple,
        orientation: :vertical,
        inner_block: TestHelpers.slot("Items")
      })

    assert html =~ "data-slot=\"toggle-group\""
    assert html =~ "data-type=\"multiple\""
    assert html =~ "data-orientation=\"vertical\""
    assert html =~ "role=\"group\""
  end
end
