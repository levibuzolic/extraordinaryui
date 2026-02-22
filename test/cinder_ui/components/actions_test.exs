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
end
