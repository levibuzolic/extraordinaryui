defmodule ExtraordinaryUI.Hooks do
  @moduledoc """
  JS hook integration helpers.

  The actual hooks are shipped in `assets/js/extraordinary_ui.js` and installed
  into host apps via `mix extraordinary_ui.install`.
  """

  @doc """
  Returns an import snippet for Phoenix `assets/js/app.js`.
  """
  @spec app_js_snippet() :: String.t()
  def app_js_snippet do
    """
    import { ExtraordinaryUIHooks } from \"./extraordinary_ui\"
    Object.assign(Hooks, ExtraordinaryUIHooks)
    """
    |> String.trim()
  end
end
