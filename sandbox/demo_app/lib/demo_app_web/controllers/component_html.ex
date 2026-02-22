defmodule DemoAppWeb.ComponentHTML do
  @moduledoc """
  HTML templates for component previews.
  """

  use DemoAppWeb, :html

  embed_templates "component_html/*"
end
