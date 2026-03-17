defmodule CinderUI.UI do
  @moduledoc """
  Facade module that delegates every component function, allowing conflict-free
  access via a single alias.

  ## Usage

      # In your html_helpers
      alias CinderUI.UI

      # In templates
      <UI.button>Click me</UI.button>
      <UI.autocomplete id="search" name="q" value="">
        <:option value="foo" label="Foo" />
      </UI.autocomplete>

  This is useful in projects that have existing components (e.g., Phoenix
  CoreComponents) with overlapping names like `button`, `input`, or `table`.
  """

  @component_modules [
    CinderUI.Icons,
    CinderUI.Components.Actions,
    CinderUI.Components.Advanced,
    CinderUI.Components.DataDisplay,
    CinderUI.Components.Feedback,
    CinderUI.Components.Forms,
    CinderUI.Components.Layout,
    CinderUI.Components.Navigation,
    CinderUI.Components.Overlay
  ]

  # Internal Phoenix.Component functions that should not be delegated
  @skip_functions [:__phoenix_component_verify__]

  for mod <- @component_modules do
    for {func, 1} <- mod.__info__(:functions), func not in @skip_functions do
      @doc false
      def unquote(func)(assigns), do: unquote(mod).unquote(func)(assigns)
    end
  end
end
