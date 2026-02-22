defmodule ExtraordinaryUI.Components.FormsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias ExtraordinaryUI.Components.Forms

  test "input renders with data-slot" do
    html = render_component(&Forms.input/1, %{id: "email", type: "email"})
    assert html =~ "data-slot=\"input\""
    assert html =~ "type=\"email\""
  end

  test "select renders options" do
    html =
      render_component(&Forms.select/1, %{
        name: "role",
        value: "admin",
        option: [
          %{value: "user", label: "User", inner_block: fn -> "" end},
          %{value: "admin", label: "Admin", inner_block: fn -> "" end}
        ]
      })

    assert html =~ "Admin"
    assert html =~ "data-slot=\"native-select-wrapper\""
    assert html =~ "data-slot=\"native-select\""
    assert html =~ "data-slot=\"native-select-icon\""
    assert html =~ "pr-9"
    assert html =~ "right-3.5"
  end
end
