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
end
