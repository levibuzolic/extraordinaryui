defmodule DemoAppWeb.ComponentController do
  use DemoAppWeb, :controller

  alias DemoApp.SiteRuntime

  def index(conn, _params) do
    serve_site_path(conn, [])
  end

  def components(conn, _params) do
    serve_site_path(conn, ["docs"])
  end

  def rebuild(conn, _params) do
    SiteRuntime.rebuild_site!()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "rebuild complete")
  end

  def site(conn, %{"path" => path}) do
    serve_site_path(conn, path)
  end

  defp serve_site_path(conn, path_segments) do
    SiteRuntime.ensure_site_built!()

    case SiteRuntime.resolve_request_path(path_segments) do
      nil ->
        send_resp(conn, 404, "Not found")

      absolute_path ->
        if File.exists?(absolute_path) do
          content_type =
            absolute_path
            |> MIME.from_path()
            |> normalize_content_type()

          conn
          |> put_resp_content_type(content_type)
          |> send_file(200, absolute_path)
        else
          send_resp(conn, 404, "Not found")
        end
    end
  end

  defp normalize_content_type("application/octet-stream"), do: "text/plain"
  defp normalize_content_type(content_type), do: content_type
end
