defmodule DemoAppWeb.ComponentController do
  use DemoAppWeb, :controller

  alias ExtraordinaryUI.Docs.Catalog

  def index(conn, _params) do
    render(conn, :index,
      sections: Catalog.sections(),
      component_count: Catalog.entry_count()
    )
  end
end
