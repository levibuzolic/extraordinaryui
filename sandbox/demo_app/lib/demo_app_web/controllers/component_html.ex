defmodule DemoAppWeb.ComponentHTML do
  @moduledoc """
  HTML templates for component previews.
  """

  use DemoAppWeb, :html
  alias CinderUI.Components.{Forms, Navigation}

  embed_templates "component_html/*"
end
