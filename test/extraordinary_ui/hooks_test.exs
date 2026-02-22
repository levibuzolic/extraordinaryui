defmodule ExtraordinaryUI.HooksTest do
  use ExUnit.Case, async: true

  alias ExtraordinaryUI.Hooks

  test "app_js_snippet returns hook integration snippet" do
    snippet = Hooks.app_js_snippet()

    assert snippet =~ "import { ExtraordinaryUIHooks } from \"./extraordinary_ui\""
    assert snippet =~ "Object.assign(Hooks, ExtraordinaryUIHooks)"
  end
end
