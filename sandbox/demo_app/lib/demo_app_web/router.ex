defmodule DemoAppWeb.Router do
  use DemoAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :site_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoAppWeb.Layouts, :root}
    plug :put_secure_browser_headers
  end

  scope "/", DemoAppWeb do
    pipe_through :site_browser

    get "/", ComponentController, :index
    get "/components", ComponentController, :components
    post "/__docs/rebuild", ComponentController, :rebuild
    get "/*path", ComponentController, :site
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoAppWeb do
  #   pipe_through :api
  # end
end
