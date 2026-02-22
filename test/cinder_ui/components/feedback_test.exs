defmodule CinderUI.Components.FeedbackTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias CinderUI.Components.Feedback
  alias CinderUI.TestHelpers

  test "badge renders variant" do
    html =
      render_component(&Feedback.badge/1, %{
        variant: :secondary,
        inner_block: TestHelpers.slot("New")
      })

    assert html =~ "data-slot=\"badge\""
    assert html =~ "New"
  end

  test "progress renders indicator transform" do
    html = render_component(&Feedback.progress/1, %{value: 50})
    assert html =~ "data-slot=\"progress\""
    assert html =~ "translateX(-50.0%)"
  end

  test "toast renders container and item" do
    html =
      render_component(&Feedback.toast/1, %{
        position: :bottom_right,
        inner_block: TestHelpers.slot("<div data-slot=\"toast-item\">Saved</div>")
      })

    assert html =~ "data-slot=\"toast\""
    assert html =~ "data-position=\"bottom_right\""
  end

  test "toast_item supports destructive variant" do
    html =
      render_component(&Feedback.toast_item/1, %{
        variant: :destructive,
        inner_block: TestHelpers.slot("Delete failed")
      })

    assert html =~ "data-slot=\"toast-item\""
    assert html =~ "data-variant=\"destructive\""
    assert html =~ "Delete failed"
  end
end
