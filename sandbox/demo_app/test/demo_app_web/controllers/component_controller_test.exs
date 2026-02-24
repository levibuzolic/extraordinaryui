defmodule DemoAppWeb.ComponentControllerTest do
  use DemoAppWeb.ConnCase

  test "GET / renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)

    assert response =~ "Component Library"
    assert response =~ "Copy HEEx"
  end

  test "GET /docs renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/docs")
    response = html_response(conn, 200)

    assert response =~ "Component Library"
    assert response =~ "Copy HEEx"
  end

  test "GET /docs and / share live catalog output", %{conn: conn} do
    docs_response = conn |> get(~p"/docs") |> html_response(200)
    root_response = conn |> recycle() |> get(~p"/") |> html_response(200)

    assert docs_response =~ "Copy HEEx"
    assert root_response =~ "Copy HEEx"
  end

  test "GET /docs/assets/site.js serves shared docs script", %{conn: conn} do
    conn = get(conn, ~p"/docs/assets/site.js")
    response = response(conn, 200)
    content_type = conn |> get_resp_header("content-type") |> List.first()

    assert content_type =~ "javascript"
    assert response =~ "cui:theme:mode"
    assert response =~ "window.CinderUISiteShared"
    assert response =~ "highlightCodeBlocks"
    assert response =~ "syncOpenButtons"
    assert response =~ "aria-expanded"
  end

  test "GET /docs/assets/site.css serves docs stylesheet", %{conn: conn} do
    conn = get(conn, ~p"/docs/assets/site.css")
    response = response(conn, 200)
    content_type = conn |> get_resp_header("content-type") |> List.first()

    assert content_type =~ "css"
    assert response =~ ".code-highlight"
  end
end
