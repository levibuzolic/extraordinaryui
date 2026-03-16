defmodule CinderUI.Docs.UIComponents.Shell do
  @moduledoc false

  use Phoenix.Component

  import CinderUI.Classes

  alias CinderUI.Components.{Actions, Advanced, Forms}
  alias CinderUI.Icons

  attr :href, :string, required: true
  attr :variant, :atom, default: :outline
  attr :size, :atom, default: :sm
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def docs_external_link_button(assigns) do
    ~H"""
    <Actions.button
      as="a"
      href={@href}
      target="_blank"
      rel="noopener noreferrer"
      variant={@variant}
      size={@size}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </Actions.button>
    """
  end

  attr :class, :string, default: nil
  attr :button_class, :string, default: nil
  attr :rest, :global

  def theme_mode_toggle(assigns) do
    assigns =
      assigns
      |> assign(:root_classes, [
        "theme-mode-toggle inline-flex items-center rounded-full border border-border/70 bg-card/80 p-1 shadow-sm backdrop-blur-xs",
        assigns.class
      ])
      |> assign(:item_classes, [
        "theme-mode-btn inline-flex size-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/60",
        assigns.button_class
      ])

    ~H"""
    <div class={classes(@root_classes)} role="group" aria-label="Theme mode" {@rest}>
      <button
        type="button"
        data-theme-mode="light"
        aria-label="Use light theme"
        title="Light theme"
        class={classes(@item_classes)}
      >
        <Icons.icon name="sun" class="size-4" />
      </button>
      <button
        type="button"
        data-theme-mode="dark"
        aria-label="Use dark theme"
        title="Dark theme"
        class={classes(@item_classes)}
      >
        <Icons.icon name="moon" class="size-4" />
      </button>
      <button
        type="button"
        data-theme-mode="auto"
        aria-label="Use system theme"
        title="System theme"
        class={classes(@item_classes)}
      >
        <Icons.icon name="monitor" class="size-4" />
      </button>
    </div>
    """
  end

  attr :sections, :list, default: []
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :active_entry_id, :string, default: nil
  attr :active_page, :atom, default: nil
  attr :home_url, :string, default: nil
  attr :github_url, :string, default: nil
  attr :hex_package_url, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def docs_layout(assigns) do
    ~H"""
    <Advanced.sidebar_layout
      data-docs-sidebar
      collapsible={:none}
      class="mx-auto max-w-[1900px]"
      style="visibility: hidden;"
      {@rest}
    >
      <:header>
        <Advanced.sidebar_header class="items-start px-4 py-5">
          <div class="min-w-0 flex-1">
            <h1 class="text-[1.75rem] leading-none font-semibold tracking-tight">
              <%= if is_binary(@home_url) and @home_url != "" do %>
                <a href={@home_url}>Cinder UI</a>
              <% else %>
                Cinder UI
              <% end %>
            </h1>
            <p class="text-muted-foreground mt-2 text-xs uppercase tracking-[0.18em]">Component docs</p>
          </div>
          <.docs_header_links github_url={@github_url} hex_package_url={@hex_package_url} />
        </Advanced.sidebar_header>
      </:header>

      <:sidebar class="border-border/70" content_class="px-3 pb-4">
        <.docs_theme_controls class="mb-4" />
        <.docs_search_button class="mb-4" />

        <nav class="space-y-4" aria-label="Component sections">
          <.docs_sidebar
            sections={@sections}
            mode={@mode}
            root_prefix={@root_prefix}
            active_entry_id={@active_entry_id}
            active_page={@active_page}
          />
        </nav>
      </:sidebar>

      <:main class="min-w-0 px-5 py-6 lg:px-8">
        <div class="space-y-6">
          <script>
            (() => {
              const root = document.currentScript?.closest("[data-docs-sidebar]");
              const content = root?.querySelector("[data-slot='sidebar-content']");
              if (!root || !content) return;

              try {
                const key = "cui:docs:sidebar-scroll-top";
                const saved = Number.parseInt(sessionStorage.getItem(key) || "", 10);
                if (Number.isFinite(saved) && saved >= 0) content.scrollTop = saved;
              } catch (_error) {}

              root.style.removeProperty("visibility");
            })();
          </script>

          {render_slot(@inner_block)}
        </div>
      </:main>
    </Advanced.sidebar_layout>
    """
  end

  attr :github_url, :string, default: nil
  attr :hex_package_url, :string, default: nil
  attr :rest, :global

  def docs_header_links(assigns) do
    ~H"""
    <div
      :if={
        (is_binary(@github_url) and @github_url != "") or
          (is_binary(@hex_package_url) and @hex_package_url != "")
      }
      class="flex shrink-0 flex-col gap-2 text-xs"
      {@rest}
    >
      <.docs_external_link_button
        :if={is_binary(@github_url) and @github_url != ""}
        href={@github_url}
        variant={:outline}
        size={:xs}
        class="h-8 justify-center px-3"
      >
        GitHub
      </.docs_external_link_button>
      <.docs_external_link_button
        :if={is_binary(@hex_package_url) and @hex_package_url != ""}
        href={@hex_package_url}
        variant={:outline}
        size={:xs}
        class="h-8 justify-center px-3"
      >
        Hex
      </.docs_external_link_button>
    </div>
    """
  end

  attr :sections, :list, default: []
  attr :mode, :atom, default: :static
  attr :root_prefix, :string, default: "."
  attr :active_entry_id, :string, default: nil
  attr :active_page, :atom, default: nil
  attr :rest, :global

  def docs_sidebar(assigns) do
    ~H"""
    <div {@rest}>
      <Advanced.sidebar_group label="Docs" label_class="uppercase tracking-[0.14em] text-[11px] font-semibold">
        <Advanced.sidebar_item
          href={install_href(@mode, @root_prefix)}
          current={@active_page == :install}
        >
          Installation
        </Advanced.sidebar_item>
        <Advanced.sidebar_item
          href={overview_href(@mode, @root_prefix)}
          current={@active_page == :overview}
        >
          Overview
        </Advanced.sidebar_item>
      </Advanced.sidebar_group>

      <%= for section <- @sections do %>
        <Advanced.sidebar_group
          label={section.title}
          label_class="uppercase tracking-[0.14em] text-[11px] font-semibold"
          class="mt-6"
        >
          <Advanced.sidebar_item
            :for={entry <- section.entries}
            href={entry_href(@mode, @root_prefix, entry)}
            current={entry.id == @active_entry_id}
          >
            {entry.title}
          </Advanced.sidebar_item>
        </Advanced.sidebar_group>
      <% end %>
    </div>
    """
  end

  attr :rest, :global

  def docs_theme_controls(assigns) do
    assigns =
      assigns
      |> assign(:color_options, color_options())
      |> assign(:radius_options, radius_options())

    ~H"""
    <section class="mb-6 rounded-xl border p-3" {@rest}>
      <div class="space-y-1">
        <p class="text-xs font-medium text-muted-foreground">Theme</p>
        <p class="text-sm font-medium">Appearance</p>
      </div>

      <div class="mt-3 flex justify-center">
        <.theme_mode_toggle />
      </div>

      <div class="mt-3">
        <Forms.label for="theme-color" class="mb-2 block text-xs font-medium text-muted-foreground">
          Color
        </Forms.label>
        <Forms.select
          name="theme-color"
          value="neutral"
          id="theme-color"
          aria-label="Theme color"
        >
          <:option :for={option <- @color_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>

      <div class="mt-3">
        <Forms.label for="theme-radius" class="mb-2 block text-xs font-medium text-muted-foreground">
          Radius
        </Forms.label>
        <Forms.select
          name="theme-radius"
          value="nova"
          id="theme-radius"
          aria-label="Theme radius"
        >
          <:option :for={option <- @radius_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>
    </section>
    """
  end

  attr :rest, :global

  def docs_search_button(assigns) do
    ~H"""
    <div class="mb-5" {@rest}>
      <Actions.button
        type="button"
        variant={:outline}
        data-open-command-palette
        class="h-10 w-full justify-between px-3 text-sm"
      >
        <span>Search components</span>
        <span class="text-muted-foreground shrink-0 text-xs">⌘K</span>
      </Actions.button>
    </div>
    """
  end

  defp color_options do
    Enum.map(["gray", "neutral", "slate", "stone", "zinc"], fn option ->
      %{value: option, label: option |> String.replace("_", " ") |> String.capitalize()}
    end)
  end

  defp radius_options do
    Enum.map(
      [
        {"maia", "Compact (6px / 0.375rem)"},
        {"mira", "Small (8px / 0.5rem)"},
        {"nova", "Default (12px / 0.75rem)"},
        {"lyra", "Large (14px / 0.875rem)"},
        {"vega", "XL (16px / 1rem)"}
      ],
      fn {value, label} -> %{value: value, label: label} end
    )
  end

  defp overview_href(:static, root_prefix), do: "#{root_prefix}/"
  defp overview_href(:live, _root_prefix), do: "/docs"

  defp install_href(:static, root_prefix), do: "#{root_prefix}/install/"
  defp install_href(:live, _root_prefix), do: "/docs/install/"

  defp entry_href(:static, root_prefix, entry),
    do: "#{root_prefix}/#{String.replace_suffix(entry.docs_path, "/index.html", "/")}"

  defp entry_href(:live, _root_prefix, entry), do: "/docs/#{entry.id}/"
end
