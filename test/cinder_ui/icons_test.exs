defmodule CinderUI.IconsTest do
  use ExUnit.Case, async: false

  import Phoenix.LiveViewTest

  alias CinderUI.Icons

  test "icon renders SVG through lucide_icons provider" do
    html = render_component(&Icons.icon/1, %{name: "chevron-down", class: "size-4"})

    assert html =~ "<svg"
    assert html =~ "size-4"
    assert html =~ "lucide-chevron-down"
  end

  test "icon accepts snake_case names" do
    html = render_component(&Icons.icon/1, %{name: "chevron_down"})

    assert html =~ "<svg"
    assert html =~ "lucide-chevron-down"
  end

  test "icon raises descriptive error when lucide_icons dependency is unavailable" do
    previous = Application.get_env(:cinder_ui, :lucide_icons_module)
    Application.put_env(:cinder_ui, :lucide_icons_module, CinderUI.MissingLucideProvider)

    on_exit(fn ->
      if previous do
        Application.put_env(:cinder_ui, :lucide_icons_module, previous)
      else
        Application.delete_env(:cinder_ui, :lucide_icons_module)
      end
    end)

    assert_raise ArgumentError, ~r/optional dependency :lucide_icons is not available/, fn ->
      render_component(&Icons.icon/1, %{name: "chevron-down"})
    end
  end

  test "icon raises helpful message for unknown names" do
    assert_raise ArgumentError, ~r/unknown icon name/, fn ->
      render_component(&Icons.icon/1, %{name: "not-a-real-icon"})
    end
  end
end
