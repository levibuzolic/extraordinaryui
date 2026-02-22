defmodule ExtraordinaryUI.Components.Actions do
  @moduledoc """
  Action-oriented shadcn-style components.

  This module includes:

  - `button/1`
  - `button_group/1`
  - `toggle/1`
  - `toggle_group/1`

  ## Usage

      <.button>Save</.button>
      <.button variant={:outline} size={:sm}>Cancel</.button>
  """

  use Phoenix.Component

  import ExtraordinaryUI.Classes

  @button_variants %{
    default: "bg-primary text-primary-foreground hover:bg-primary/90",
    destructive:
      "bg-destructive text-white hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    outline:
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:border-input dark:hover:bg-input/50",
    secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
    link: "text-primary underline-offset-4 hover:underline"
  }

  @button_sizes %{
    default: "h-9 px-4 py-2 has-[>svg]:px-3",
    xs:
      "h-6 gap-1 rounded-md px-2 text-xs has-[>svg]:px-1.5 [&_svg:not([class*='size-'])]:size-3",
    sm: "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5",
    lg: "h-10 rounded-md px-6 has-[>svg]:px-4",
    icon: "size-9",
    icon_xs: "size-6 rounded-md [&_svg:not([class*='size-'])]:size-3",
    icon_sm: "size-8",
    icon_lg: "size-10"
  }

  @doc """
  Renders a shadcn-style button.

  ## Attributes

  - `variant`: `:default | :destructive | :outline | :secondary | :ghost | :link`
  - `size`: `:default | :xs | :sm | :lg | :icon | :icon_xs | :icon_sm | :icon_lg`
  - `as`: html tag (`"button"` by default, often `"a"`)
  - `loading`: toggles an inline spinner

  ## Examples

  ```heex title="Outline small action"
  <.button variant={:outline} size={:sm}>Edit</.button>
  ```

  ```heex title="Loading destructive action"
  <.button variant={:destructive} loading={true}>Deleting...</.button>
  ```
  """
  attr :as, :string, default: "button"

  attr :variant, :atom,
    default: :default,
    values: [:default, :destructive, :outline, :secondary, :ghost, :link]

  attr :size, :atom,
    default: :default,
    values: [:default, :xs, :sm, :lg, :icon, :icon_xs, :icon_sm, :icon_lg]

  attr :loading, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(type href target rel disabled name value form id aria-label)
  slot :inner_block, required: true

  def button(assigns) do
    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        variant(@button_variants, assigns.variant, @button_variants.default),
        variant(@button_sizes, assigns.size, @button_sizes.default),
        assigns.class
      ])

    ~H"""
    <.dynamic_tag
      data-slot="button"
      data-variant={@variant}
      data-size={@size}
      tag_name={@as}
      class={classes(@classes)}
      {@rest}
    >
      <svg
        :if={@loading}
        class="size-4 animate-spin"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        aria-hidden="true"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8v4l3-3-3-3v4a10 10 0 00-10 10h2z"
        />
      </svg>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  @doc """
  Renders a horizontal or vertical button group.

  ## Example

      <.button_group>
        <.button size={:sm}>Back</.button>
        <.button size={:sm}>Next</.button>
      </.button_group>
  """
  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def button_group(assigns) do
    orientation_classes =
      case assigns.orientation do
        :horizontal -> "inline-flex items-center gap-2"
        :vertical -> "inline-flex flex-col gap-2"
      end

    assigns = assign(assigns, :classes, [orientation_classes, assigns.class])

    ~H"""
    <div data-slot="button-group" data-orientation={@orientation} class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @toggle_variants %{
    default: "bg-transparent",
    outline:
      "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
  }

  @toggle_sizes %{
    default: "h-9 px-2 min-w-9",
    sm: "h-8 px-1.5 min-w-8",
    lg: "h-10 px-2.5 min-w-10"
  }

  @doc """
  Renders a shadcn-style toggle button.

  ## Example

      <.toggle pressed={true}>Bold</.toggle>
  """
  attr :pressed, :boolean, default: false
  attr :variant, :atom, default: :default, values: [:default, :outline]
  attr :size, :atom, default: :default, values: [:default, :sm, :lg]
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(type id name value disabled aria-label)
  slot :inner_block, required: true

  def toggle(assigns) do
    state = if(assigns.pressed, do: "on", else: "off")

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:classes, [
        "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium hover:bg-muted hover:text-muted-foreground disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0 focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] outline-none transition-[color,box-shadow] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive whitespace-nowrap",
        variant(@toggle_variants, assigns.variant, @toggle_variants.default),
        variant(@toggle_sizes, assigns.size, @toggle_sizes.default),
        assigns.class
      ])

    ~H"""
    <button
      type="button"
      data-slot="toggle"
      data-state={@state}
      aria-pressed={@pressed}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Groups toggles in either single-select or multi-select mode.

  This component provides structure and classes only. State management should be
  handled by LiveView assigns or JS hooks.

  ## Example

      <.toggle_group type={:single}>
        <.toggle pressed={@value == "left"}>Left</.toggle>
        <.toggle pressed={@value == "center"}>Center</.toggle>
        <.toggle pressed={@value == "right"}>Right</.toggle>
      </.toggle_group>
  """
  attr :type, :atom, default: :single, values: [:single, :multiple]
  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def toggle_group(assigns) do
    orientation_classes =
      case assigns.orientation do
        :horizontal -> "inline-flex items-center gap-1"
        :vertical -> "inline-flex flex-col gap-1"
      end

    assigns = assign(assigns, :classes, [orientation_classes, assigns.class])

    ~H"""
    <div
      data-slot="toggle-group"
      data-type={@type}
      data-orientation={@orientation}
      role="group"
      class={classes(@classes)}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
