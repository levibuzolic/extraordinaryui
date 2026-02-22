defmodule ExtraordinaryUI.Components do
  @moduledoc """
  Aggregates all component modules.
  """

  defmacro __using__(_opts) do
    quote do
      import ExtraordinaryUI.Components.Advanced
      import ExtraordinaryUI.Components.Actions
      import ExtraordinaryUI.Components.DataDisplay
      import ExtraordinaryUI.Components.Feedback
      import ExtraordinaryUI.Components.Forms
      import ExtraordinaryUI.Components.Layout
      import ExtraordinaryUI.Components.Navigation
      import ExtraordinaryUI.Components.Overlay
    end
  end
end
