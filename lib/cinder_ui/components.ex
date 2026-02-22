defmodule CinderUI.Components do
  @moduledoc """
  Aggregates all component modules.
  """

  defmacro __using__(_opts) do
    quote do
      import CinderUI.Components.Advanced
      import CinderUI.Components.Actions
      import CinderUI.Components.DataDisplay
      import CinderUI.Components.Feedback
      import CinderUI.Components.Forms
      import CinderUI.Components.Layout
      import CinderUI.Components.Navigation
      import CinderUI.Components.Overlay
    end
  end
end
