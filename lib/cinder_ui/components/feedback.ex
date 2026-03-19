defmodule CinderUI.Components.Feedback do
  @moduledoc """
  Feedback and status components.

  Included:

  - `badge/1`
  - `alert/1`
  - `flash/1`
  - `flash_group/1`
  - `progress/1`
  - `spinner/1`
  - `empty_state/1`
  """

  use Phoenix.Component

  import CinderUI.Classes
  import CinderUI.ComponentDocs, only: [doc: 1]
  alias Phoenix.LiveView.JS

  @badge_variants %{
    solid: %{
      primary: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
      secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
      destructive:
        "bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
      success: "bg-success text-success-foreground [a&]:hover:bg-success/90",
      warning: "bg-warning text-warning-foreground [a&]:hover:bg-warning/90",
      info: "bg-info text-info-foreground [a&]:hover:bg-info/90"
    },
    outline: %{
      primary:
        "border-primary text-primary [a&]:hover:bg-primary [a&]:hover:text-primary-foreground",
      secondary:
        "border-secondary text-secondary [a&]:hover:bg-secondary [a&]:hover:text-secondary-foreground",
      destructive:
        "border-destructive text-destructive [a&]:hover:bg-destructive [a&]:hover:text-destructive-foreground",
      success:
        "border-success text-success [a&]:hover:bg-success [a&]:hover:text-success-foreground",
      warning:
        "border-warning text-warning [a&]:hover:bg-warning [a&]:hover:text-warning-foreground",
      info: "border-info text-info [a&]:hover:bg-info [a&]:hover:text-info-foreground"
    },
    ghost: %{
      primary: "[a&]:hover:bg-primary/10 [a&]:hover:text-primary",
      secondary: "[a&]:hover:bg-secondary/10 [a&]:hover:text-secondary",
      destructive: "[a&]:hover:bg-destructive/10 [a&]:hover:text-destructive",
      success: "[a&]:hover:bg-success/10 [a&]:hover:text-success",
      warning: "[a&]:hover:bg-warning/10 [a&]:hover:text-warning",
      info: "[a&]:hover:bg-info/10 [a&]:hover:text-info"
    },
    link: %{
      primary: "text-primary underline-offset-4 [a&]:hover:underline",
      secondary: "text-secondary underline-offset-4 [a&]:hover:underline",
      destructive: "text-destructive underline-offset-4 [a&]:hover:underline",
      success: "text-success underline-offset-4 [a&]:hover:underline",
      warning: "text-warning underline-offset-4 [a&]:hover:underline",
      info: "text-info underline-offset-4 [a&]:hover:underline"
    }
  }

  doc("""
  Renders a status badge.

  ## Colors

  `:primary`, `:secondary`, `:destructive`, `:success`, `:warning`, `:info`

  ## Variants

  `:solid`, `:outline`, `:ghost`, `:link`

  ## Examples

  ```heex title="Default badge"
  <.badge>New</.badge>
  ```

  ```heex title="All colors and variants" align="full"
  <div class="space-y-6">
    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Primary</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:primary} variant={:solid}>Solid</.badge>
        <.badge color={:primary} variant={:outline}>Outline</.badge>
        <.badge color={:primary} variant={:ghost}>Ghost</.badge>
        <.badge color={:primary} variant={:link}>Link</.badge>
      </div>
    </div>

    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Secondary</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:secondary} variant={:solid}>Solid</.badge>
        <.badge color={:secondary} variant={:outline}>Outline</.badge>
        <.badge color={:secondary} variant={:ghost}>Ghost</.badge>
        <.badge color={:secondary} variant={:link}>Link</.badge>
      </div>
    </div>

    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Destructive</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:destructive} variant={:solid}>Solid</.badge>
        <.badge color={:destructive} variant={:outline}>Outline</.badge>
        <.badge color={:destructive} variant={:ghost}>Ghost</.badge>
        <.badge color={:destructive} variant={:link}>Link</.badge>
      </div>
    </div>

    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Success</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:success} variant={:solid}>Solid</.badge>
        <.badge color={:success} variant={:outline}>Outline</.badge>
        <.badge color={:success} variant={:ghost}>Ghost</.badge>
        <.badge color={:success} variant={:link}>Link</.badge>
      </div>
    </div>

    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Warning</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:warning} variant={:solid}>Solid</.badge>
        <.badge color={:warning} variant={:outline}>Outline</.badge>
        <.badge color={:warning} variant={:ghost}>Ghost</.badge>
        <.badge color={:warning} variant={:link}>Link</.badge>
      </div>
    </div>

    <div class="space-y-2">
      <h4 class="text-sm font-medium text-muted-foreground">Info</h4>
      <div class="flex gap-2 flex-wrap">
        <.badge color={:info} variant={:solid}>Solid</.badge>
        <.badge color={:info} variant={:outline}>Outline</.badge>
        <.badge color={:info} variant={:ghost}>Ghost</.badge>
        <.badge color={:info} variant={:link}>Link</.badge>
      </div>
    </div>
  </div>
  ```

  ```heex title="Badge with icon"
  <.badge color={:secondary}>
    <CinderUI.Icons.icon name="check" />
    Verified
  </.badge>
  ```
  """)

  attr :color, :atom,
    default: :primary,
    values: [:primary, :secondary, :destructive, :success, :warning, :info]

  attr :variant, :atom,
    default: :solid,
    values: [:solid, :outline, :ghost, :link]

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    variant_styles = variant(@badge_variants, assigns.variant, @badge_variants.solid)
    color_styles = variant(variant_styles, assigns.color, variant_styles.primary)

    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center justify-center rounded-full border border-transparent px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
        color_styles,
        assigns.class
      ])

    ~H"""
    <span
      data-slot="badge"
      data-color={@color}
      data-variant={@variant}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @alert_variants %{
    default: "bg-card text-card-foreground",
    destructive:
      "border-destructive/30 bg-destructive/10 text-destructive [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90",
    success:
      "border-emerald-500/30 bg-emerald-500/10 text-emerald-700 [&>svg]:text-current *:data-[slot=alert-description]:text-emerald-700/90",
    warning:
      "border-amber-500/30 bg-amber-500/10 text-amber-700 [&>svg]:text-current *:data-[slot=alert-description]:text-amber-700/90",
    info:
      "border-info/30 bg-info/10 text-info [&>svg]:text-current *:data-[slot=alert-description]:text-info/90"
  }

  doc("""
  Renders an alert container.

  Use named `:title` and `:description` slots for canonical structure.

  ## Examples

  ```heex title="All alert variants" align="full"
  <div class="space-y-4">
    <div>
      <h4 class="text-sm font-medium mb-2">Default</h4>
      <.alert>
        <CinderUI.Icons.icon name="circle-alert" />
        <:title>Heads up!</:title>
        <:description>
          You can add components to your app using the install task.
        </:description>
      </.alert>
    </div>

    <div>
      <h4 class="text-sm font-medium mb-2">Destructive</h4>
      <.alert variant={:destructive}>
        <CinderUI.Icons.icon name="triangle-alert" />
        <:title>Unable to deploy</:title>
        <:description>
          Your build failed. Check logs and try again.
        </:description>
      </.alert>
    </div>

    <div>
      <h4 class="text-sm font-medium mb-2">Success</h4>
      <.alert variant={:success}>
        <CinderUI.Icons.icon name="circle-check-big" />
        <:title>Changes saved</:title>
        <:description>
          Your updates have been successfully saved to the server.
        </:description>
      </.alert>
    </div>

    <div>
      <h4 class="text-sm font-medium mb-2">Warning</h4>
      <.alert variant={:warning}>
        <CinderUI.Icons.icon name="triangle-alert" />
        <:title>Deprecated API</:title>
        <:description>
          This endpoint will be removed in the next major version.
        </:description>
      </.alert>
    </div>

    <div>
      <h4 class="text-sm font-medium mb-2">Info</h4>
      <.alert variant={:info}>
        <CinderUI.Icons.icon name="info" />
        <:title>FYI</:title>
        <:description>
          Additional information to help you understand the current situation.
        </:description>
      </.alert>
    </div>
  </div>
  ```
  """)

  attr :id, :string, default: nil

  attr :variant, :atom,
    default: :default,
    values: [:default, :destructive, :success, :warning, :info]

  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true
  slot :title
  slot :description

  def alert(assigns) do
    assigns =
      assign(assigns, :classes, [
        "relative w-full rounded-lg border px-4 py-3 text-sm grid has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr] has-[>svg]:gap-x-3 gap-y-0.5 items-start has-[>svg]:[&>svg]:row-span-2 [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current",
        variant(@alert_variants, assigns.variant, @alert_variants.default),
        assigns.class
      ])

    ~H"""
    <div
      id={@id}
      data-slot="alert"
      data-variant={@variant}
      role="alert"
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
      <div
        :if={@title != []}
        data-slot="alert-title"
        class="col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight"
      >
        {render_slot(@title)}
      </div>
      <div
        :if={@description != []}
        data-slot="alert-description"
        class="col-start-2 text-sm opacity-90"
      >
        {render_slot(@description)}
      </div>
    </div>
    """
  end

  doc("""
  Renders a flash notice.

  Drop-in replacement for the Phoenix generated `flash/1` core component.
  Accepts the same attributes and slots, so you can swap it in without
  changing any call sites.

  To replace the default Phoenix flash, remove the `flash/1` function from
  your `core_components.ex` and add `import CinderUI.Components.Feedback`
  (or `use CinderUI.Components` which imports all modules).

  ## Examples

  ```heex title="Info flash"
  <.flash kind={:info}>Settings saved.</.flash>
  ```

  ```heex title="Error flash"
  <.flash kind={:error}>Unable to save changes.</.flash>
  ```

  ```heex title="Success flash"
  <.flash kind={:success}>Workspace created.</.flash>
  ```

  ```heex title="Warning flash"
  <.flash kind={:warning}>Trial ends in 3 days.</.flash>
  ```
  """)

  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [:info, :error, :success, :warning],
    doc: "used for styling and flash lookup"

  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    flash_config = flash_config(assigns.kind)

    assigns =
      assigns
      |> assign_new(:id, fn -> "flash-#{assigns.kind}" end)
      |> assign(:variant, flash_config.variant)
      |> assign(:style_classes, flash_config.style_classes)
      |> assign(:icon_name, flash_config.icon_name)

    ~H"""
    <.alert
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      variant={@variant}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.hide(to: "##{@id}")}
      class={
        classes([
          "fixed top-2 right-2 z-50 w-80 sm:w-96 pr-12",
          @style_classes
        ])
      }
      {@rest}
    >
      <CinderUI.Icons.icon name={@icon_name} class="size-4 shrink-0" />
      <:title>{@title || msg}</:title>
      <:description :if={@title}>{msg}</:description>
      <button
        type="button"
        class="absolute top-3 right-3 rounded-md p-1 hover:bg-black/10 dark:hover:bg-white/10"
        aria-label="Close"
      >
        <CinderUI.Icons.icon name="x" class="size-4 opacity-60" />
      </button>
    </.alert>
    """
  end

  defp flash_config(:error) do
    %{
      variant: :destructive,
      style_classes: "border-destructive/40 bg-destructive/10 text-destructive",
      icon_name: "circle-alert"
    }
  end

  defp flash_config(:success) do
    %{
      variant: :success,
      style_classes: "border-emerald-500/30 bg-emerald-500/10 text-emerald-700",
      icon_name: "circle-check-big"
    }
  end

  defp flash_config(:warning) do
    %{
      variant: :warning,
      style_classes: "border-amber-500/30 bg-amber-500/10 text-amber-700",
      icon_name: "triangle-alert"
    }
  end

  defp flash_config(_kind) do
    %{
      variant: :default,
      style_classes: "border-primary/20 bg-primary/10 text-primary",
      icon_name: "info"
    }
  end

  doc("""
  Shows the flash group with standard titles and content.

  Drop-in replacement for the Phoenix generated `flash_group/1` core component.
  Includes the same client-error and server-error reconnection notices.

  To replace the default, remove `flash_group/1` from your `core_components.ex`.

  ## Example

      <.flash_group flash={%{"info" => "Saved", "error" => "Unable to complete request"}} />
  """)

  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"
  attr :rest, :global

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" {@rest}>
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={
          JS.show(to: ".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: "#client-error")
        }
        phx-connected={
          JS.hide(to: "#client-error")
          |> JS.set_attribute({"hidden", ""}, to: "#client-error")
        }
        hidden
      >
        Attempting to reconnect
        <CinderUI.Icons.icon name="loader-circle" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={
          JS.show(to: ".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: "#server-error")
        }
        phx-connected={
          JS.hide(to: "#server-error")
          |> JS.set_attribute({"hidden", ""}, to: "#server-error")
        }
        hidden
      >
        Attempting to reconnect
        <CinderUI.Icons.icon name="loader-circle" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  doc("""
  Progress bar.

  `value` is clamped between `0` and `max`.

  ## Example

  ```heex title="Progress indicator" align="full"
  <div class="space-y-2">
    <div class="flex items-center justify-between text-sm">
      <span>Deploy progress</span>
      <span>72%</span>
    </div>
    <.progress value={72} />
  </div>
  ```
  """)

  attr :value, :integer, default: 0
  attr :max, :integer, default: 100
  attr :class, :string, default: nil
  attr :rest, :global

  def progress(assigns) do
    max = if(assigns.max <= 0, do: 100, else: assigns.max)
    clamped = assigns.value |> max(0) |> min(max)
    percentage = Float.round(clamped * 100 / max, 2)

    assigns =
      assigns
      |> assign(:max, max)
      |> assign(:percentage, percentage)
      |> assign(:classes, [
        "bg-primary/20 relative h-2 w-full overflow-hidden rounded-full",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="progress"
      class={classes(@classes)}
      role="progressbar"
      aria-valuemin="0"
      aria-valuemax={@max}
      aria-valuenow={@value}
      {@rest}
    >
      <div
        data-slot="progress-indicator"
        class="bg-primary h-full w-full flex-1 transition-all"
        style={"transform: translateX(-#{100 - @percentage}%);"}
      />
    </div>
    """
  end

  doc("""
  Generic loading spinner.

  ## Example

  ```heex title="Inline spinner"
  <div class="inline-flex items-center gap-2 text-sm text-muted-foreground">
    <.spinner />
    Syncing changes
  </div>
  ```
  """)

  attr :class, :string, default: nil
  attr :rest, :global

  def spinner(assigns) do
    assigns =
      assign(assigns, :classes, ["size-4 animate-spin text-muted-foreground", assigns.class])

    ~H"""
    <CinderUI.Icons.icon
      data-slot="spinner"
      name="loader-circle"
      class={classes(@classes)}
      aria-hidden="true"
      {@rest}
    />
    """
  end

  doc("""
  Empty-state block for no-data screens.

  ## Example

      <.empty_state>
        <:title>No projects</:title>
        <:description>Create your first project to get started.</:description>
      </.empty_state>
  """)

  attr :class, :string, default: nil
  attr :rest, :global
  slot :icon
  slot :title
  slot :description
  slot :action

  def empty_state(assigns) do
    assigns =
      assign(assigns, :classes, [
        "border-border bg-card text-card-foreground flex flex-col items-center justify-center rounded-xl border border-dashed px-8 py-10 text-center",
        assigns.class
      ])

    ~H"""
    <div data-slot="empty" class={classes(@classes)} {@rest}>
      <div :if={@icon != []} class="text-muted-foreground mb-3">{render_slot(@icon)}</div>
      <h3 :if={@title != []} class="text-base font-semibold">{render_slot(@title)}</h3>
      <p :if={@description != []} class="text-muted-foreground mt-2 text-sm">
        {render_slot(@description)}
      </p>
      <div :if={@action != []} class="mt-4">{render_slot(@action)}</div>
    </div>
    """
  end
end
