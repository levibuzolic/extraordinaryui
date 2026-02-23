defmodule CinderUI.Components.Feedback do
  @moduledoc """
  Feedback and status components.

  Included:

  - `badge/1`
  - `alert/1`
  - `alert_title/1`
  - `alert_description/1`
  - `progress/1`
  - `spinner/1`
  - `toast/1`
  - `toast_item/1`
  - `empty_state/1`
  """

  use Phoenix.Component

  import CinderUI.Classes

  @badge_variants %{
    default: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive:
      "bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline:
      "border-border text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    ghost: "[a&]:hover:bg-accent [a&]:hover:text-accent-foreground",
    link: "text-primary underline-offset-4 [a&]:hover:underline"
  }

  @doc """
  Renders a status badge.

  ## Variants

  `:default`, `:secondary`, `:destructive`, `:outline`, `:ghost`, `:link`

  ## Examples

  ```heex title="Default badge"
  <.badge>New</.badge>
  ```

  ```heex title="Variant set"
  <div class="flex flex-wrap items-center gap-2">
    <.badge>Default</.badge>
    <.badge variant={:secondary}>Secondary</.badge>
    <.badge variant={:destructive}>Destructive</.badge>
    <.badge variant={:outline}>Outline</.badge>
  </div>
  ```

  ```heex title="Badge with icon"
  <.badge variant={:secondary}>
    <CinderUI.Icons.icon name="check" />
    Verified
  </.badge>
  ```
  """
  attr :variant, :atom,
    default: :default,
    values: [:default, :secondary, :destructive, :outline, :ghost, :link]

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def badge(assigns) do
    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center justify-center rounded-full border border-transparent px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
        variant(@badge_variants, assigns.variant, @badge_variants.default),
        assigns.class
      ])

    ~H"""
    <span data-slot="badge" data-variant={@variant} class={classes(@classes)}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @alert_variants %{
    default: "bg-card text-card-foreground",
    destructive:
      "text-destructive bg-card [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
  }

  @doc """
  Renders an alert container.

  Compose with `alert_title/1` and `alert_description/1` for canonical structure.

  ## Examples

  ```heex title="Default alert" align="full"
  <.alert>
    <CinderUI.Icons.icon name="circle-alert" />
    <.alert_title>Heads up!</.alert_title>
    <.alert_description>
      You can add components to your app using the install task.
    </.alert_description>
  </.alert>
  ```

  ```heex title="Destructive alert" align="full"
  <.alert variant={:destructive}>
    <CinderUI.Icons.icon name="triangle-alert" />
    <.alert_title>Unable to deploy</.alert_title>
    <.alert_description>
      Your build failed. Check logs and try again.
    </.alert_description>
  </.alert>
  ```
  """
  attr :variant, :atom, default: :default, values: [:default, :destructive]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert(assigns) do
    assigns =
      assign(assigns, :classes, [
        "relative w-full rounded-lg border px-4 py-3 text-sm grid has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr] has-[>svg]:gap-x-3 gap-y-0.5 items-start [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current",
        variant(@alert_variants, assigns.variant, @alert_variants.default),
        assigns.class
      ])

    ~H"""
    <div data-slot="alert" data-variant={@variant} role="alert" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Alert title element.

  ## Example

  ```heex title="Title within alert" align="full"
  <.alert>
    <CinderUI.Icons.icon name="circle-alert" />
    <.alert_title>Heads up!</.alert_title>
    <.alert_description>
      This action requires admin access.
    </.alert_description>
  </.alert>
  ```
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_title(assigns) do
    assigns =
      assign(assigns, :classes, [
        "col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight",
        assigns.class
      ])

    ~H"""
    <div data-slot="alert-title" class={classes(@classes)}>{render_slot(@inner_block)}</div>
    """
  end

  @doc """
  Alert description element.

  ## Example

  ```heex title="Description within alert" align="full"
  <.alert variant={:destructive}>
    <CinderUI.Icons.icon name="triangle-alert" />
    <.alert_title>Build failed</.alert_title>
    <.alert_description>
      Your tests failed during CI. Review the logs and re-run.
    </.alert_description>
  </.alert>
  ```
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def alert_description(assigns) do
    assigns =
      assign(assigns, :classes, [
        "text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed",
        assigns.class
      ])

    ~H"""
    <div data-slot="alert-description" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Progress bar.

  `value` is clamped between `0` and `max`.
  """
  attr :value, :integer, default: 0
  attr :max, :integer, default: 100
  attr :class, :string, default: nil

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
    >
      <div
        data-slot="progress-indicator"
        class="bg-primary h-full w-full flex-1 transition-all"
        style={"transform: translateX(-#{100 - @percentage}%);"}
      />
    </div>
    """
  end

  @doc """
  Generic loading spinner.
  """
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

  @doc """
  Toast container for stacking notification items.

  This is a presentational primitive intended to wrap one or more `toast_item/1`
  children.
  """
  attr :position, :atom,
    default: :bottom_right,
    values: [:top_left, :top_center, :top_right, :bottom_left, :bottom_center, :bottom_right]

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def toast(assigns) do
    position_classes =
      case assigns.position do
        :top_left -> "top-0 left-0"
        :top_center -> "top-0 left-1/2 -translate-x-1/2"
        :top_right -> "top-0 right-0"
        :bottom_left -> "bottom-0 left-0"
        :bottom_center -> "bottom-0 left-1/2 -translate-x-1/2"
        :bottom_right -> "bottom-0 right-0"
      end

    assigns =
      assign(assigns, :classes, [
        "pointer-events-none fixed z-50 flex w-full max-w-[420px] flex-col gap-2 p-4",
        position_classes,
        assigns.class
      ])

    ~H"""
    <div data-slot="toast" data-position={@position} class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Toast item panel.
  """
  attr :variant, :atom, default: :default, values: [:default, :destructive]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def toast_item(assigns) do
    variant_class =
      case assigns.variant do
        :default -> "border bg-card text-card-foreground"
        :destructive -> "border-destructive/60 bg-destructive/5 text-foreground"
      end

    assigns =
      assign(assigns, :classes, [
        "pointer-events-auto rounded-lg px-4 py-3 text-sm shadow-lg",
        variant_class,
        assigns.class
      ])

    ~H"""
    <div data-slot="toast-item" data-variant={@variant} role="status" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Empty-state block for no-data screens.

  ## Example

      <.empty_state>
        <:title>No projects</:title>
        <:description>Create your first project to get started.</:description>
      </.empty_state>
  """
  attr :class, :string, default: nil
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
    <div data-slot="empty" class={classes(@classes)}>
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
