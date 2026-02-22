defmodule CinderUI.Hooks do
  @moduledoc """
  JS hook integration helpers.

  The actual hooks are shipped in `assets/js/cinder_ui.js` and installed
  into host apps via `mix cinder_ui.install`.
  """

  @doc """
  Returns an import snippet for Phoenix `assets/js/app.js`.
  """
  @spec app_js_snippet() :: String.t()
  def app_js_snippet do
    """
    import { CinderUIHooks } from \"./cinder_ui\"
    Object.assign(Hooks, CinderUIHooks)
    """
    |> String.trim()
  end
end
