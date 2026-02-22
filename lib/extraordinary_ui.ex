defmodule ExtraordinaryUI do
  @moduledoc """
  Entry-point helpers for the Extraordinary UI component system.

  `use ExtraordinaryUI` in your component modules to import all component
  functions exposed by `ExtraordinaryUI.Components`.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import ExtraordinaryUI.Components
      import ExtraordinaryUI.Classes
    end
  end
end
