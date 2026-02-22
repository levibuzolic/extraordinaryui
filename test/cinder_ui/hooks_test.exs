defmodule CinderUI.HooksTest do
  use ExUnit.Case, async: true

  alias CinderUI.Hooks

  test "app_js_snippet returns hook integration snippet" do
    snippet = Hooks.app_js_snippet()

    assert snippet =~ "import { CinderUIHooks } from \"./cinder_ui\""
    assert snippet =~ "Object.assign(Hooks, CinderUIHooks)"
  end
end
