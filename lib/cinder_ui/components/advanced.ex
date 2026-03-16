defmodule CinderUI.Components.Advanced do
  @moduledoc """
  Higher-level components that map to shadcn patterns with progressive enhancement.

  Included:

  - `command/1`
  - `combobox/1`
  - `carousel/1`
  - `chart/1`
  - `sidebar/1`
  - `sidebar_header/1`
  - `sidebar_footer/1`
  - `sidebar_content/1`
  - `sidebar_group/1`
  - `sidebar_item/1`
  - `sidebar_trigger/1`
  - `item/1`

  These components intentionally favor no-JS defaults and expose hooks/classes so
  advanced interactions can be layered in using LiveView hooks.
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]

  alias CinderUI.Icons

  doc("""
  Command palette layout.

  This renders the shell of a command palette (`input + list + items`).

  ## Examples

  ```heex title="Command palette" align="full"
  <.command placeholder="Search commands...">
    <:group heading="General">
      <.item value="profile">Profile</.item>
      <.item value="billing">Billing</.item>
    </:group>

    <:group heading="Workspace">
      <.item value="settings">Settings</.item>
    </:group>
  </.command>
  ```

  ```heex title="Project switcher" align="full"
  <.command placeholder="Jump to project...">
    <:group heading="Projects">
      <.item value="docs">Docs site</.item>
      <.item value="demo">Demo app</.item>
    </:group>

    <:group heading="Teams">
      <.item value="platform">Platform team</.item>
    </:group>
  </.command>
  ```
  """)

  attr :class, :string, default: nil
  attr :placeholder, :string, default: "Type a command..."
  attr :rest, :global

  slot :group do
    attr :heading, :string
  end

  def command(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-popover text-popover-foreground flex h-full w-full flex-col overflow-hidden rounded-md border shadow-md",
        assigns.class
      ])

    ~H"""
    <div data-slot="command" class={classes(@classes)} {@rest}>
      <div data-slot="command-input-wrapper" class="flex items-center border-b px-3">
        <input
          data-slot="command-input"
          type="text"
          placeholder={@placeholder}
          class="flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-muted-foreground"
        />
      </div>

      <div data-slot="command-list" class="max-h-[300px] overflow-y-auto overflow-x-hidden p-1">
        <div
          :for={group <- @group}
          data-slot="command-group"
          class="overflow-hidden p-1 text-foreground"
        >
          <div
            :if={group[:heading]}
            data-slot="command-group-heading"
            class="text-muted-foreground px-2 py-1.5 text-xs font-medium"
          >
            {group.heading}
          </div>
          <div class="space-y-1">{render_slot(group)}</div>
        </div>
      </div>
    </div>
    """
  end

  doc("""
  Command/list item.

  ## Example

  ```heex title="Command item" align="full"
  <.command>
    <:group heading="General">
      <.item value="profile">Profile</.item>
    </:group>
  </.command>
  ```
  """)

  attr :class, :string, default: nil
  attr :value, :string, default: nil
  attr :disabled, :boolean, default: false
  attr :rest, :global
  slot :inner_block, required: true

  def item(assigns) do
    assigns =
      assign(assigns, :classes, [
        "relative flex cursor-default items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden select-none data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-50 aria-selected:bg-accent aria-selected:text-accent-foreground",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="item"
      role="option"
      data-value={@value}
      data-disabled={@disabled}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Combobox scaffold using an input and option list.

  It is intentionally unopinionated on state and filtering logic.

  ## When to use it

  Use `combobox/1` when you want a lightweight client-side filter input that
  simply writes the selected label back into the visible text field.

  Prefer `autocomplete/1` when the selected value needs to submit through a
  hidden input, when labels and values differ, or when the control participates
  in a larger form workflow.

  ## Example

  ```heex title="Combobox" align="full"
  <.combobox id="plan" value="Pro">
    <:option value="Free" label="Free" />
    <:option value="Pro" label="Pro" />
  </.combobox>
  ```
  """)

  attr :id, :string, required: true
  attr :class, :string, default: nil
  attr :placeholder, :string, default: "Select an option"
  attr :value, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def combobox(assigns) do
    assigns = assign(assigns, :classes, ["relative w-full", assigns.class])

    ~H"""
    <div id={@id} data-slot="combobox" class={classes(@classes)} phx-hook="CuiCombobox" {@rest}>
      <input
        data-slot="combobox-input"
        data-combobox-input
        value={@value}
        placeholder={@placeholder}
        class="file:text-foreground placeholder:text-muted-foreground border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs outline-none disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"
      />
      <div
        data-slot="combobox-content"
        data-combobox-content
        class="bg-popover text-popover-foreground absolute z-50 mt-2 hidden w-full rounded-md border p-1 shadow-md"
      >
        <button
          :for={option <- @option}
          type="button"
          data-slot="combobox-item"
          data-value={option.value}
          class={
            classes([
              "relative flex w-full cursor-default items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-hidden select-none data-[highlighted=true]:bg-accent data-[highlighted=true]:text-accent-foreground"
            ])
          }
        >
          {option.label}
          <span
            data-slot="select-check"
            class={
              classes([
                "absolute right-2 flex size-3.5 items-center justify-center",
                @value != option.value && "hidden"
              ])
            }
          >
            <Icons.icon name="check" class="size-4" aria-hidden="true" />
          </span>
        </button>
      </div>
    </div>
    """
  end

  doc("""
  Carousel shell.

  Render slides in `:item` slots and wire interactions with a LiveView hook or
  external script.

  ## Example

  ```heex title="Carousel" align="full"
  <.carousel id="feature-carousel">
    <:item><div class="rounded-md bg-muted p-8 text-sm">Slide one</div></:item>
    <:item><div class="rounded-md bg-muted/60 p-8 text-sm">Slide two</div></:item>
  </.carousel>
  ```

  ```heex title="Autoplay with indicators" align="full"
  <.carousel id="marketing-carousel" autoplay={4000} indicators={true}>
    <:item><div class="rounded-md bg-muted p-8 text-sm">Overview</div></:item>
    <:item><div class="rounded-md bg-muted/60 p-8 text-sm">Analytics</div></:item>
    <:item><div class="rounded-md bg-muted/40 p-8 text-sm">Deployments</div></:item>
  </.carousel>
  ```
  """)

  attr :id, :string, required: true
  attr :autoplay, :integer, default: nil
  attr :indicators, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :item, required: true

  def carousel(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative", assigns.class])
      |> assign(:item_count, length(assigns.item))

    ~H"""
    <div
      id={@id}
      data-slot="carousel"
      data-autoplay={@autoplay}
      role="region"
      aria-roledescription="carousel"
      class={classes(@classes)}
      phx-hook="CuiCarousel"
      {@rest}
    >
      <div data-slot="carousel-content" class="overflow-hidden">
        <div class="flex" data-carousel-track>
          <div
            :for={item <- @item}
            data-slot="carousel-item"
            role="group"
            aria-roledescription="slide"
            class="min-w-0 shrink-0 grow-0 basis-full"
          >
            {render_slot(item)}
          </div>
        </div>
      </div>

      <button
        type="button"
        data-slot="carousel-previous"
        data-carousel-prev
        aria-label="Previous slide"
        class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        <Icons.icon name="chevron-left" class="size-4" />
      </button>
      <button
        type="button"
        data-slot="carousel-next"
        data-carousel-next
        aria-label="Next slide"
        class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full border bg-background p-2"
      >
        <Icons.icon name="chevron-right" class="size-4" />
      </button>

      <div
        :if={@indicators and @item_count > 1}
        data-slot="carousel-indicators"
        class="mt-4 flex items-center justify-center gap-2"
      >
        <button
          :for={index <- Enum.to_list(0..(@item_count - 1))}
          type="button"
          data-slot="carousel-indicator"
          data-carousel-indicator={index}
          data-active={index == 0}
          aria-label={"Go to slide #{index + 1}"}
          class="bg-muted-foreground/30 data-[active=true]:bg-primary h-2.5 w-2.5 rounded-full transition-colors"
        />
      </div>
    </div>
    """
  end

  doc("""
  Chart frame component for wrapping chart libraries with shadcn tokens.

  ## Example

  ```heex title="Chart shell" align="full"
  <.chart>
    <:title>Traffic</:title>
    <:description>Requests over the last 7 days.</:description>
    <div class="h-40 rounded-md bg-muted/60"></div>
  </.chart>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :title
  slot :description
  slot :inner_block, required: true

  def chart(assigns) do
    assigns = assign(assigns, :classes, ["rounded-xl border bg-card p-4", assigns.class])

    ~H"""
    <section data-slot="chart" class={classes(@classes)} {@rest}>
      <header :if={@title != [] or @description != []} class="mb-4">
        <h3 :if={@title != []} class="text-sm font-semibold">{render_slot(@title)}</h3>
        <p :if={@description != []} class="text-muted-foreground text-sm">
          {render_slot(@description)}
        </p>
      </header>
      <div data-slot="chart-content">{render_slot(@inner_block)}</div>
    </section>
    """
  end

  doc("""
  Phoenix-first sidebar shell for app layouts.

  This component is designed for LiveView and server-rendered Phoenix apps,
  rather than mirroring shadcn's React-only primitive structure. Compose the
  shell with `sidebar_header/1`, `sidebar_content/1`, `sidebar_group/1`, and
  `sidebar_item/1`.

  Use `default_open` for the default uncontrolled behavior. Pass `open` to let
  LiveView control the current state, and pair it with `toggle_event` if the
  built-in trigger should push a server event instead of toggling locally.

  By default the sidebar shell stretches to the viewport height. Set
  `full_screen={false}` when rendering inside a nested panel or container that
  already manages its own height.

  ## Examples

  ```heex title="Workspace shell" align="full" vrt
  <.sidebar id="workspace-shell-sidebar" persist_key="docs:workspace-shell">
    <:header>
      <.sidebar_header>
        <button
          type="button"
          class="hover:bg-sidebar-accent hover:text-sidebar-accent-foreground flex w-full items-center gap-3 rounded-lg px-2 py-2 text-left transition-colors"
        >
          <div class="bg-sidebar-primary text-sidebar-primary-foreground flex size-8 items-center justify-center rounded-lg">
            <.icon name="briefcase-business" class="size-4" />
          </div>
          <div data-sidebar-label class="min-w-0 flex-1">
            <p class="truncate text-sm font-medium">Acme Inc</p>
            <p class="text-sidebar-foreground/70 truncate text-xs">Enterprise</p>
          </div>
          <div data-sidebar-label class="text-sidebar-foreground/70 flex flex-col">
            <.icon name="chevron-up" class="size-3" />
            <.icon name="chevron-down" class="size-3 -mt-1" />
          </div>
        </button>
      </.sidebar_header>
    </:header>

    <.sidebar_content>
      <.sidebar_group label="Platform">
        <.sidebar_item icon="square-play" current={true}>
          Playground
          <:trailing>
            <.icon name="chevron-down" class="size-3.5" />
          </:trailing>
        </.sidebar_item>
        <.sidebar_item inset={true}>History</.sidebar_item>
        <.sidebar_item inset={true}>Starred</.sidebar_item>
        <.sidebar_item inset={true}>Settings</.sidebar_item>
        <.sidebar_item icon="bot">
          Models
          <:trailing><.icon name="chevron-right" class="size-3.5" /></:trailing>
        </.sidebar_item>
        <.sidebar_item icon="book-open">
          Documentation
          <:trailing><.icon name="chevron-right" class="size-3.5" /></:trailing>
        </.sidebar_item>
        <.sidebar_item icon="settings-2">
          Settings
          <:trailing><.icon name="chevron-right" class="size-3.5" /></:trailing>
        </.sidebar_item>
      </.sidebar_group>
    </.sidebar_content>

    <:footer>
      <.sidebar_footer>
        <button
          type="button"
          class="hover:bg-sidebar-accent hover:text-sidebar-accent-foreground flex w-full items-center gap-3 rounded-lg px-2 py-2 text-left transition-colors"
        >
          <img src="example.png" alt="shadcn avatar" class="size-8 rounded-full object-cover" />
          <div data-sidebar-label class="min-w-0 flex-1">
            <p class="truncate text-sm font-medium">shadcn</p>
            <p class="text-sidebar-foreground/70 truncate text-xs">m@example.com</p>
          </div>
          <div data-sidebar-label class="text-sidebar-foreground/70 flex flex-col">
            <.icon name="chevron-up" class="size-3" />
            <.icon name="chevron-down" class="size-3 -mt-1" />
          </div>
        </button>
      </.sidebar_footer>
    </:footer>

    <:inset>
      <div class="space-y-4">
        <div class="flex h-7 items-center">
          <.sidebar_trigger />
        </div>
      </div>
    </:inset>
  </.sidebar>
  ```

  ```heex title="Collapsed by default" align="full"
  <.sidebar id="collapsed-sidebar" default_open={false} full_screen={false}>
    <.sidebar_content>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Home</.sidebar_item>
        <.sidebar_item icon="inbox">Inbox</.sidebar_item>
        <.sidebar_item icon="settings">Settings</.sidebar_item>
      </.sidebar_group>
    </.sidebar_content>

    <:inset>
      <div class="space-y-4">
        <div class="flex h-7 items-center">
          <.sidebar_trigger />
        </div>
        <div class="rounded-xl border bg-card p-4 text-sm">Compact inset content</div>
      </div>
    </:inset>
  </.sidebar>
  ```

  ```heex title="Server-controlled open state" align="full"
  <.sidebar
    id="server-controlled-sidebar"
    open={false}
    toggle_event="sidebar:set_open"
    full_screen={false}
  >
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        <.sidebar_trigger />
      </.sidebar_header>
    </:header>

    <.sidebar_content>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
        <.sidebar_item icon="settings">Settings</.sidebar_item>
      </.sidebar_group>
    </.sidebar_content>

    <:inset>
      <div class="rounded-xl border bg-card p-4 text-sm">
        Sidebar state comes from LiveView assigns.
      </div>
    </:inset>
  </.sidebar>
  ```
  """)

  attr :id, :string, default: nil
  attr :open, :boolean, default: nil
  attr :default_open, :boolean, default: true
  attr :toggle_event, :string, default: nil
  attr :full_screen, :boolean, default: true
  attr :collapsible, :atom, default: :icon, values: [:icon, :none]
  attr :persist_key, :string, default: nil
  attr :class, :string, default: nil
  attr :sidebar_class, :string, default: nil
  attr :inset_class, :string, default: nil
  attr :rest, :global

  slot :header
  slot :footer
  slot :inner_block
  slot :inset, required: true

  def sidebar(assigns) do
    id = assigns.id || "cinder-ui-sidebar-#{System.unique_integer([:positive])}"

    state =
      cond do
        is_boolean(assigns.open) and assigns.open -> "expanded"
        is_boolean(assigns.open) -> "collapsed"
        assigns.default_open -> "expanded"
        true -> "collapsed"
      end

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:state, state)
      |> assign(:controlled, is_boolean(assigns.open))
      |> assign(:classes, [
        "group/sidebar grid w-full grid-cols-1 transition-[grid-template-columns] duration-200 md:grid-cols-[var(--cui-sidebar-width)_minmax(0,1fr)]",
        assigns.full_screen && "min-h-screen",
        !assigns.full_screen && "h-full min-h-0",
        assigns.collapsible == :icon &&
          "data-[state=collapsed]:md:grid-cols-[var(--cui-sidebar-width-icon)_minmax(0,1fr)] data-[state=collapsed]:[&_[data-sidebar-label]]:hidden",
        assigns.class
      ])
      |> assign(:sidebar_classes, [
        "bg-sidebar text-sidebar-foreground border-sidebar-border min-h-0 border-r",
        assigns.sidebar_class
      ])
      |> assign(:panel_classes, [
        "flex h-full min-h-0 flex-col overflow-hidden"
      ])
      |> assign(:inset_classes, [
        "bg-background text-foreground min-h-0 min-w-0 p-4 md:p-6",
        assigns.inset_class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="sidebar"
      data-state={@state}
      data-sidebar-controlled={@controlled}
      data-sidebar-toggle-event={@toggle_event}
      data-collapsible={@collapsible}
      data-sidebar-persist-key={@persist_key}
      style="--cui-sidebar-width: 16rem; --cui-sidebar-width-icon: 3rem;"
      class={classes(@classes)}
      phx-hook="CuiSidebar"
      {@rest}
    >
      <aside data-slot="sidebar-panel" class={classes(@sidebar_classes)}>
        <div class={classes(@panel_classes)}>
          <%= if @header != [] do %>
            {render_slot(@header)}
          <% end %>

          {render_slot(@inner_block)}

          <%= if @footer != [] do %>
            {render_slot(@footer)}
          <% end %>
        </div>
      </aside>

      <main data-slot="sidebar-inset" class={classes(@inset_classes)}>
        {render_slot(@inset)}
      </main>
    </div>
    """
  end

  doc("""
  Sidebar header container.

  Use this inside `sidebar/1` for branding, workspace selectors, or the
  collapse trigger.

  ## Example

  ```heex title="Sidebar header" align="full"
  <.sidebar id="sidebar-header-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        <.sidebar_trigger />
      </.sidebar_header>
    </:header>
    <:inset><div class="rounded border bg-card p-4 text-sm">Inset</div></:inset>
  </.sidebar>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_header(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-sidebar sticky top-0 z-10 flex min-h-12 items-center gap-2 px-2 py-2",
        assigns.class
      ])

    ~H"""
    <header data-slot="sidebar-header" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </header>
    """
  end

  doc("""
  Sidebar footer container.

  Use this inside `sidebar/1` for profile, workspace status, or secondary
  actions anchored at the bottom.

  ## Example

  ```heex title="Sidebar footer" align="full"
  <.sidebar id="sidebar-footer-example" full_screen={false}>
    <.sidebar_content />
    <:footer>
      <.sidebar_footer>
        <div data-sidebar-label class="text-sm">Free plan</div>
        <.button size={:xs} variant={:outline}>Upgrade</.button>
      </.sidebar_footer>
    </:footer>
    <:inset><div class="rounded border bg-card p-4 text-sm">Inset</div></:inset>
  </.sidebar>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def sidebar_footer(assigns) do
    assigns =
      assign(assigns, :classes, [
        "bg-sidebar sticky bottom-0 z-10 mt-auto flex min-h-12 items-center gap-2 px-2 py-2",
        assigns.class
      ])

    ~H"""
    <footer data-slot="sidebar-footer" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </footer>
    """
  end

  doc("""
  Scrollable content region for sidebar groups.

  ## Example

  ```heex title="Sidebar content" align="full"
  <.sidebar id="sidebar-content-example" full_screen={false}>
    <.sidebar_content>
      <.sidebar_group label="Navigation">
        <.sidebar_item icon="home" current={true}>Home</.sidebar_item>
        <.sidebar_item icon="inbox">Inbox</.sidebar_item>
      </.sidebar_group>
    </.sidebar_content>
    <:inset><div class="rounded border bg-card p-4 text-sm">Inset</div></:inset>
  </.sidebar>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: false

  def sidebar_content(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex min-h-0 flex-1 flex-col gap-2 overflow-y-auto px-2 pb-2",
        assigns.class
      ])

    ~H"""
    <div data-slot="sidebar-content" class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  doc("""
  Sidebar group wrapper.

  Groups are useful for labeled sections such as navigation, tools, or account
  controls. Pass `label` for the section heading and render `sidebar_item/1`
  children directly inside the group.

  ## Example

  ```heex title="Sidebar group" align="full"
  <.sidebar id="sidebar-group-example" full_screen={false}>
    <.sidebar_content>
      <.sidebar_group label="Workspace">
        <.sidebar_item icon="folder-kanban" current={true}>Projects</.sidebar_item>
        <.sidebar_item icon="ship-wheel" badge="2">Deployments</.sidebar_item>
        <.sidebar_item icon="message-square">Feedback</.sidebar_item>
      </.sidebar_group>

      <.sidebar_group label="Insights">
        <.sidebar_item icon="chart-column">Analytics</.sidebar_item>
        <.sidebar_item icon="bell-ring" badge="4">Alerts</.sidebar_item>
      </.sidebar_group>
    </.sidebar_content>
    <:inset>
      <div class="rounded border bg-card p-4 text-sm">
        A sidebar can stack multiple labeled groups while keeping each section
        visually separate.
      </div>
    </:inset>
  </.sidebar>
  ```
  """)

  attr :label, :string, default: nil
  attr :class, :string, default: nil
  attr :label_class, :string, default: nil
  attr :rest, :global
  slot :action
  slot :inner_block, required: true

  def sidebar_group(assigns) do
    assigns =
      assigns
      |> assign(:classes, ["relative flex w-full min-w-0 flex-col gap-1", assigns.class])
      |> assign(:label_classes, [
        "text-sidebar-foreground/70 flex h-8 items-center px-2 text-xs font-medium",
        "group-data-[state=collapsed]/sidebar:-mt-8 group-data-[state=collapsed]/sidebar:opacity-0",
        assigns.label_class
      ])

    ~H"""
    <section data-slot="sidebar-group" class={classes(@classes)} {@rest}>
      <div :if={@label || @action != []} class="flex items-center gap-2">
        <div data-sidebar-label class={classes(@label_classes)}>{@label}</div>
        <div :if={@action != []} data-sidebar-label class="ml-auto pr-2">
          {render_slot(@action)}
        </div>
      </div>
      <div data-slot="sidebar-group-items" class="space-y-1">
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  doc("""
  Sidebar navigation item.

  Use this inside `sidebar_group/1` for app routes, navigation rows, and
  nested secondary items.

  ## Examples

  ```heex title="Sidebar item" align="full"
  <.sidebar_group label="Navigation">
    <.sidebar_item icon="home" current={true}>Overview</.sidebar_item>
    <.sidebar_item icon="inbox">Inbox</.sidebar_item>
  </.sidebar_group>
  ```

  ```heex title="Route targets and trailing content" align="full"
  <.sidebar_group label="Workspace">
    <.sidebar_item icon="folder-kanban" navigate="/docs" current={true}>
      Docs
      <:trailing><.icon name="chevron-right" class="size-3.5" /></:trailing>
    </.sidebar_item>
    <.sidebar_item icon="ship-wheel" href="#deployments" badge="3">
      Deployments
    </.sidebar_item>
    <.sidebar_item inset={true}>Recent activity</.sidebar_item>
  </.sidebar_group>
  ```
  """)

  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :href, :string, default: nil
  attr :icon, :string, default: nil
  attr :badge, :string, default: nil
  attr :current, :boolean, default: false
  attr :inset, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :trailing
  slot :inner_block, required: true

  def sidebar_item(assigns) do
    assigns =
      assign(assigns, :classes, [
        "ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground flex h-8 w-full min-w-0 items-center gap-2 rounded-md px-2 text-left text-sm text-sidebar-foreground outline-none transition-colors focus-visible:ring-2 active:bg-sidebar-accent active:text-sidebar-accent-foreground",
        "group-data-[state=collapsed]/sidebar:mx-auto group-data-[state=collapsed]/sidebar:size-8 group-data-[state=collapsed]/sidebar:justify-center group-data-[state=collapsed]/sidebar:px-0",
        assigns.current && "bg-sidebar-accent text-sidebar-accent-foreground font-medium",
        assigns.inset &&
          "h-7 pl-8 text-sidebar-foreground/80 group-data-[state=collapsed]/sidebar:hidden",
        assigns.disabled && "pointer-events-none opacity-50",
        assigns.class
      ])

    ~H"""
    <div data-slot="sidebar-item">
      <%= cond do %>
        <% @navigate -> %>
          <.link
            navigate={@navigate}
            aria-current={if(@current, do: "page", else: nil)}
            class={classes(@classes)}
            {@rest}
          >
            <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
              {render_slot(@inner_block)}
            </.sidebar_item_inner>
          </.link>
        <% @patch -> %>
          <.link
            patch={@patch}
            aria-current={if(@current, do: "page", else: nil)}
            class={classes(@classes)}
            {@rest}
          >
            <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
              {render_slot(@inner_block)}
            </.sidebar_item_inner>
          </.link>
        <% @href -> %>
          <.link
            href={@href}
            aria-current={if(@current, do: "page", else: nil)}
            class={classes(@classes)}
            {@rest}
          >
            <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
              {render_slot(@inner_block)}
            </.sidebar_item_inner>
          </.link>
        <% true -> %>
          <button type="button" disabled={@disabled} class={classes(@classes)} {@rest}>
            <.sidebar_item_inner icon={@icon} badge={@badge} trailing={@trailing}>
              {render_slot(@inner_block)}
            </.sidebar_item_inner>
          </button>
      <% end %>
    </div>
    """
  end

  attr :icon, :string, default: nil
  attr :badge, :string, default: nil
  attr :trailing, :any, default: []
  slot :inner_block, required: true

  defp sidebar_item_inner(assigns) do
    ~H"""
    <%= if @icon do %>
      <Icons.icon name={@icon} class="size-4 shrink-0" aria-hidden="true" />
    <% end %>
    <span data-sidebar-label class="min-w-0 flex-1 truncate">
      {render_slot(@inner_block)}
    </span>
    <span
      :if={@badge}
      data-sidebar-label
      class="bg-sidebar-primary/15 text-sidebar-primary ml-auto flex h-5 min-w-5 items-center justify-center rounded-md px-1 text-[11px] font-medium tabular-nums"
    >
      {@badge}
    </span>
    <span :if={@trailing != []} data-sidebar-label class="text-sidebar-foreground/70 ml-auto shrink-0">
      {render_slot(@trailing)}
    </span>
    """
  end

  doc("""
  Button that toggles a surrounding `sidebar/1` between expanded and collapsed.

  By default this renders the compact shadcn-style icon button. You can also
  supply your own trigger content or change the rendered tag with `as`.

  ## Example

  ```heex title="Sidebar trigger" align="full"
  <.sidebar id="sidebar-trigger-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Navigation</span>
        <.sidebar_trigger />
      </.sidebar_header>
    </:header>
    <:inset><div class="rounded border bg-card p-4 text-sm">Inset</div></:inset>
  </.sidebar>
  ```

  ```heex title="Custom trigger content" align="full"
  <.sidebar id="sidebar-trigger-custom-example" full_screen={false}>
    <:header>
      <.sidebar_header>
        <span data-sidebar-label class="text-sm font-semibold">Workspace</span>
        <.sidebar_trigger class="gap-2 px-2 text-xs">
          <.icon name="panel-left" class="size-4" />
          <span data-sidebar-label>Collapse</span>
        </.sidebar_trigger>
      </.sidebar_header>
    </:header>
    <:inset><div class="rounded border bg-card p-4 text-sm">Inset</div></:inset>
  </.sidebar>
  ```
  """)

  attr :as, :string, default: "button"
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: false

  def sidebar_trigger(assigns) do
    rest =
      if assigns.as == "button" and not Map.has_key?(assigns.rest, :type) and not Map.has_key?(assigns.rest, "type") do
        Map.put(assigns.rest, :type, "button")
      else
        assigns.rest
      end

    assigns =
      assigns
      |> assign(:rest, rest)
      |> assign(:classes, [
        "ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground inline-flex size-7 items-center justify-center rounded-md text-sidebar-foreground outline-none transition-colors focus-visible:ring-2 active:bg-sidebar-accent",
        assigns.class
      ])

    ~H"""
    <.dynamic_tag
      tag_name={@as}
      data-slot="sidebar-trigger"
      data-sidebar-trigger
      aria-label="Toggle sidebar"
      class={classes(@classes)}
      {@rest}
    >
      <%= if @inner_block == [] do %>
        <Icons.icon
          name="panel-left"
          aria-hidden="true"
          class="size-4"
        />
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </.dynamic_tag>
    """
  end
end
