defmodule DemoAppWeb.PageControllerTest do
  use DemoAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)
    assert response =~ "Demo Sandbox"
    assert response =~ "Open Component Catalog"
  end
end
