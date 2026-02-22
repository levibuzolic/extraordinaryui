defmodule CinderUI do
  @moduledoc """
  Entry-point helpers for the Cinder UI component system.

  `use CinderUI` in your component modules to import all component
  functions exposed by `CinderUI.Components`.
  """

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import CinderUI.Components
      import CinderUI.Classes
    end
  end
end
