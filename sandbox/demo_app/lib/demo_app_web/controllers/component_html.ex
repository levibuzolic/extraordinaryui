defmodule DemoAppWeb.ComponentHTML do
  @moduledoc """
  HTML templates for component previews.
  """

  use DemoAppWeb, :html
  alias CinderUI.Docs.UIComponents, as: DocsUI

  embed_templates "component_html/*"
end
