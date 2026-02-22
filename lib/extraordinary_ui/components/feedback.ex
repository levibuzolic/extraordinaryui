defmodule ExtraordinaryUI.Components.Feedback do
  @moduledoc """
  Feedback and status components.

  Included:

  - `badge/1`
  - `alert/1`
  - `alert_title/1`
  - `alert_description/1`
  - `progress/1`
  - `spinner/1`
  - `empty_state/1`
  """

  use Phoenix.Component

  import ExtraordinaryUI.Classes

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
    <svg
      data-slot="spinner"
      class={classes(@classes)}
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
      aria-hidden="true"
      {@rest}
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8v4l3-3-3-3v4a10 10 0 00-10 10h2z"
      />
    </svg>
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
