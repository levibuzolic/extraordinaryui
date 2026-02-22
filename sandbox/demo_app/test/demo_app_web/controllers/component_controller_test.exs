defmodule DemoAppWeb.ComponentControllerTest do
  use DemoAppWeb.ConnCase

  test "GET /components renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/components")
    response = html_response(conn, 200)

    assert response =~ "Extraordinary UI Sandbox"
    assert response =~ "Components:"
    assert response =~ "Actions.button/1"
    assert response =~ "data-component-card"
    assert response =~ "Phoenix template (HEEx)"
    assert response =~ "data-theme-mode"
    assert response =~ "theme-color"
    assert response =~ "theme-radius"
  end
end
