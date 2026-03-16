defmodule DemoWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use DemoWeb, :html
  alias CinderUI.Components.Feedback
  alias CinderUI.Docs.UIComponents

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="border-b bg-background/95 px-4 sm:px-6 lg:px-8">
      <div class="mx-auto flex h-16 max-w-6xl items-center justify-between gap-6">
        <a href="/" class="flex-1 flex w-fit items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
        </a>
        <ul class="flex items-center gap-3">
          <li>
            <a
              href="https://phoenixframework.org/"
              class="inline-flex h-9 items-center justify-center rounded-md px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              Website
            </a>
          </li>
          <li>
            <a
              href="https://github.com/phoenixframework/phoenix"
              class="inline-flex h-9 items-center justify-center rounded-md px-3 text-sm font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              GitHub
            </a>
          </li>
          <li>
            <.theme_toggle />
          </li>
          <li>
            <a
              href="https://hexdocs.pm/phoenix/overview.html"
              class="inline-flex h-9 items-center justify-center rounded-md bg-primary px-4 text-sm font-medium text-primary-foreground shadow-xs transition-colors hover:bg-primary/90"
            >
              Get Started <span aria-hidden="true">&rarr;</span>
            </a>
          </li>
        </ul>
      </div>
    </header>

    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-2xl space-y-4">
        {render_slot(@inner_block)}
      </div>
    </main>

    <Feedback.flash_group flash={@flash} />
    """
  end

  def theme_toggle(assigns) do
    ~H"""
    <UIComponents.theme_mode_toggle class="site-theme-toggle" />
    """
  end
end
