defmodule DemoAppWeb.ComponentController do
  use DemoAppWeb, :controller

  alias CinderUI.Docs.Catalog
  alias DemoApp.SiteRuntime

  def index(conn, _params) do
    render_catalog(conn)
  end

  def docs(conn, _params) do
    render_catalog(conn)
  end

  def docs_asset(conn, %{"path" => path}) do
    if path == ["site.js"] do
      conn
      |> put_resp_content_type("application/javascript")
      |> send_resp(200, SiteRuntime.docs_site_js())
    else
      case SiteRuntime.resolve_docs_asset_path(path) do
        nil ->
          send_resp(conn, 404, "Not found")

        absolute_path ->
          conn
          |> put_resp_content_type(MIME.from_path(absolute_path))
          |> send_file(200, absolute_path)
      end
    end
  end

  def rebuild(conn, _params) do
    SiteRuntime.rebuild_site!()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "rebuild complete")
  end

  defp render_catalog(conn) do
    sections = Catalog.sections()
    component_count = sections |> Enum.flat_map(& &1.entries) |> length()

    render(conn, :index,
      sections: sections,
      component_count: component_count
    )
  end
end
