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
end
