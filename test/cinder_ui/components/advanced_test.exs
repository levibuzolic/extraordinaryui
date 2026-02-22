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

  test "sonner_toaster renders with position" do
    html = render_component(&Advanced.sonner_toaster/1, %{position: "top-right"})
    assert html =~ "data-slot=\"sonner\""
    assert html =~ "top-4"
  end
end
