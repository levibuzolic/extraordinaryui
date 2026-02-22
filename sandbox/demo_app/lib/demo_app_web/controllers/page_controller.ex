defmodule DemoAppWeb.PageController do
  use DemoAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
