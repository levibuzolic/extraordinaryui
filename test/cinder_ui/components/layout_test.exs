defmodule CinderUI.Components.LayoutTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Layout
  alias CinderUI.TestHelpers

  test "card renders slots" do
    html = render_component(&Layout.card/1, %{inner_block: TestHelpers.slot("Body")})
    assert html =~ "data-slot=\"card\""
    assert html =~ "Body"
  end

  test "separator handles orientation" do
    html = render_component(&Layout.separator/1, %{orientation: :vertical})
    assert html =~ "data-orientation=\"vertical\""
  end
end
