defmodule CinderUI.Helpers do
  @moduledoc false
  # Internal helpers shared across CinderUI component modules.

  @doc """
  Returns true if the given map (typically a slot item or assigns) contains
  any link-related attribute (`href`, `navigate`, or `patch`).
  """
  def link?(map) do
    !!(map[:href] || map[:navigate] || map[:patch])
  end
end
