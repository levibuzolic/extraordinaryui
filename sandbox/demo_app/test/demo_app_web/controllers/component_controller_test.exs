defmodule DemoAppWeb.ComponentControllerTest do
  use DemoAppWeb.ConnCase

  test "GET / renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/")
    response = html_response(conn, 200)

    assert response =~ "Cinder UI"
    assert response =~ "Browse Component Library"
  end

  test "GET /docs renders component catalog", %{conn: conn} do
    conn = get(conn, ~p"/docs")
    response = html_response(conn, 200)

    assert response =~ "Component Library"
    assert response =~ "Copy HEEx"
  end

  test "GET / renders marketing while /docs renders live catalog", %{conn: conn} do
    docs_response = conn |> get(~p"/docs") |> html_response(200)
    root_response = conn |> recycle() |> get(~p"/") |> html_response(200)

    assert docs_response =~ "Copy HEEx"
    assert root_response =~ "Browse Component Library"
    refute root_response =~ "Copy HEEx"
  end

  test "GET /docs/components/:id renders dynamic component detail page", %{conn: conn} do
    docs_response = conn |> get(~p"/docs") |> html_response(200)

    [_, id] = Regex.run(~r/href="\/docs\/([^\/"]+)\/"/, docs_response)

    detail_response = conn |> recycle() |> get(~p"/docs/#{id}/") |> html_response(200)

    assert detail_response =~ "Back to index"
    assert detail_response =~ "Original shadcn/ui docs"
    assert detail_response =~ "Attributes"
    assert detail_response =~ "Slots"
  end

  test "GET /docs/:id returns 404 for missing component", %{conn: conn} do
    conn = get(conn, ~p"/docs/not-a-real-component/")

    assert response(conn, 404) =~ "Not found"
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

  test "GET /docs/assets/theme.css serves theme stylesheet", %{conn: conn} do
    conn = get(conn, ~p"/docs/assets/theme.css")
    response = response(conn, 200)
    content_type = conn |> get_resp_header("content-type") |> List.first()

    assert content_type =~ "css"
    assert response =~ ".bg-background" or response =~ "@source"
  end
end
