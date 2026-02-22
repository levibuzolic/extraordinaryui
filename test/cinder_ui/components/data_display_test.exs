defmodule CinderUI.Components.DataDisplayTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.DataDisplay
  alias CinderUI.TestHelpers

  test "avatar renders fallback" do
    html = render_component(&DataDisplay.avatar/1, %{alt: "Levi Noah"})
    assert html =~ "data-slot=\"avatar\""
    assert html =~ "LN"
  end

  test "table renders slots" do
    html =
      render_component(&DataDisplay.table/1, %{
        inner_block: TestHelpers.slot("<tbody></tbody>")
      })

    assert html =~ "data-slot=\"table\""
  end
end
