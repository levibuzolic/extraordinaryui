defmodule DemoAppWeb.ComponentControllerTest do
  use DemoAppWeb.ConnCase

  test "GET / renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)

    assert response =~ "shadcn/ui"
    assert response =~ "Browse Component Library"
    assert response =~ "Quick Start"
  end

  test "GET /components also renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/components")
    response = html_response(conn, 200)

    assert response =~ "Component Library"
    assert response =~ "Search components"
  end
end
