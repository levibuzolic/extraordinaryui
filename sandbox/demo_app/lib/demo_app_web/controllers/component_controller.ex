defmodule DemoAppWeb.ComponentController do
  use DemoAppWeb, :controller

  alias CinderUI.Site.Marketing
  alias DemoApp.SiteRuntime

  def index(conn, _params) do
    component_count = SiteRuntime.catalog_component_count()

    html =
      Marketing.render_marketing_html(%{
        component_count: component_count,
        docs_path: "/docs/",
        theme_css_path: "/docs/assets/theme.css",
        site_css_path: "/docs/assets/site.css"
      })

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  def docs(conn, _params) do
    render_catalog(conn)
  end

  def component(conn, %{"id" => id}) do
    sections = SiteRuntime.catalog_sections()

    case find_entry(sections, id) do
      nil ->
        send_resp(conn, 404, "Not found")

      entry ->
        render(conn, :component,
          sections: sections,
          entry: entry
        )
    end
  end

  def docs_asset(conn, %{"path" => path}) do
    cond do
      path == ["site.js"] ->
        conn
        |> put_resp_content_type("application/javascript")
        |> send_resp(200, SiteRuntime.docs_site_js())

      path == ["theme.css"] ->
        case SiteRuntime.docs_theme_css_path() do
          nil ->
            send_resp(conn, 404, "Not found")

          absolute_path ->
            conn
            |> put_resp_content_type("text/css")
            |> send_file(200, absolute_path)
        end

      true ->
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
    sections = SiteRuntime.catalog_sections()
    component_count = SiteRuntime.catalog_component_count()

    render(conn, :index,
      sections: sections,
      component_count: component_count
    )
  end

  defp find_entry(sections, id) do
    Enum.find_value(sections, fn section ->
      Enum.find(section.entries, &(&1.id == id))
    end)
  end
end
