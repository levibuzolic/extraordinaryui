defmodule DemoWeb.SiteHTML do
  @moduledoc false

  use DemoWeb, :html

  alias CinderUI.Docs.UIComponents, as: Docs

  embed_templates "site_html/*"
end
