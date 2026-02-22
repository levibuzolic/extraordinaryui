defmodule CinderUI.Components.Forms do
  @moduledoc """
  Form-related components modeled after shadcn/ui.

  Included components:

  - `label/1`
  - `field/1`
  - `input/1`
  - `textarea/1`
  - `checkbox/1`
  - `switch/1`
  - `select/1`
  - `native_select/1`
  - `radio_group/1`
  - `slider/1`
  - `input_group/1`
  - `input_otp/1`
  """

  use Phoenix.Component

  import CinderUI.Classes

  @doc """
  Renders a form label.

  ## Example

      <.label for="email">Email</.label>
  """
  attr :for, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        assigns.class
      ])

    ~H"""
    <label data-slot="label" for={@for} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Field wrapper for label, control, description, and errors.

  ## Example

      <.field>
        <:label><.label for="name">Name</.label></:label>
        <.input id="name" name="name" />
        <:description>Shown in your profile.</:description>
      </.field>
  """
  attr :class, :string, default: nil
  slot :label
  slot :description
  slot :error
  slot :inner_block, required: true

  def field(assigns) do
    assigns = assign(assigns, :classes, ["grid gap-2", assigns.class])

    ~H"""
    <div data-slot="field" class={classes(@classes)}>
      {render_slot(@label)}
      {render_slot(@inner_block)}
      <p :if={@description != []} data-slot="field-description" class="text-muted-foreground text-sm">
        {render_slot(@description)}
      </p>
      <p :if={@error != []} data-slot="field-error" class="text-destructive text-sm font-medium">
        {render_slot(@error)}
      </p>
    </div>
    """
  end

  @doc """
  Renders an input with shadcn classes.

  ## Example

      <.input id="email" type="email" placeholder="name@example.com" />
  """
  attr :id, :string, default: nil
  attr :type, :string, default: "text"
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  def input(assigns) do
    assigns =
      assign(assigns, :classes, [
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        assigns.class
      ])

    ~H"""
    <input
      id={@id}
      type={@type}
      data-slot="input"
      name={@name}
      value={@value}
      placeholder={@placeholder}
      class={classes(@classes)}
      {@rest}
    />
    """
  end

  @doc """
  Renders a textarea with shadcn classes.

  ## Example

      <.textarea id="bio" name="bio" rows={4} />
  """
  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: nil
  attr :rows, :integer, default: 4
  attr :class, :string, default: nil
  attr :rest, :global

  def textarea(assigns) do
    assigns =
      assign(assigns, :classes, [
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        assigns.class
      ])

    ~H"""
    <textarea
      id={@id}
      data-slot="textarea"
      name={@name}
      rows={@rows}
      placeholder={@placeholder}
      class={classes(@classes)}
      {@rest}
    ><%= @value %></textarea>
    """
  end

  @doc """
  Renders a checkbox control with optional inline label content.

  ## Example

      <.checkbox id="terms" name="terms">Accept terms</.checkbox>
  """
  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def checkbox(assigns) do
    assigns =
      assign(assigns, :classes, [
        "peer border-input dark:bg-input/30 checked:bg-primary checked:text-primary-foreground checked:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        assigns.class
      ])

    ~H"""
    <label class="inline-flex items-center gap-2">
      <input
        id={@id}
        data-slot="checkbox"
        type="checkbox"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class={classes(@classes)}
        {@rest}
      />
      <span :if={@inner_block != []} class="text-sm text-foreground">
        {render_slot(@inner_block)}
      </span>
    </label>
    """
  end

  @doc """
  Renders a switch control with optional label content.

  ## Example

      <.switch id="marketing" checked={@enabled}>Email updates</.switch>
  """
  attr :id, :string, required: true
  attr :name, :string, default: nil
  attr :value, :string, default: "true"
  attr :checked, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :size, :atom, default: :default, values: [:sm, :default]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block

  def switch(assigns) do
    state = if(assigns.checked, do: "checked", else: "unchecked")

    root_size =
      case assigns.size do
        :sm -> "h-3.5 w-6"
        :default -> "h-[1.15rem] w-8"
      end

    thumb_size =
      case assigns.size do
        :sm -> "size-3"
        :default -> "size-4"
      end

    thumb_position =
      case assigns.size do
        :sm -> "peer-checked:translate-x-[calc(100%-2px)]"
        :default -> "peer-checked:translate-x-[calc(100%-2px)]"
      end

    assigns =
      assigns
      |> assign(:state, state)
      |> assign(:root_size, root_size)
      |> assign(:thumb_size, thumb_size)
      |> assign(:thumb_position, thumb_position)
      |> assign(:track_classes, [
        "peer appearance-none bg-input checked:bg-primary focus-visible:border-ring focus-visible:ring-ring/50 dark:bg-input/80 dark:checked:bg-primary inline-flex shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
        root_size,
        assigns.class
      ])

    ~H"""
    <label class="inline-flex items-center gap-2">
      <span class="relative inline-flex items-center">
        <input
          id={@id}
          data-slot="switch"
          type="checkbox"
          role="switch"
          name={@name}
          value={@value}
          checked={@checked}
          disabled={@disabled}
          data-size={@size}
          data-state={@state}
          class={classes(@track_classes)}
          {@rest}
        />
        <span
          data-slot="switch-thumb"
          class={
            classes([
              "pointer-events-none absolute left-[1px] block rounded-full bg-background dark:peer-not-checked:bg-foreground dark:peer-checked:bg-primary-foreground ring-0 transition-transform peer-not-checked:translate-x-0",
              @thumb_size,
              @thumb_position
            ])
          }
        />
      </span>
      <span :if={@inner_block != []} class="text-sm text-foreground">
        {render_slot(@inner_block)}
      </span>
    </label>
    """
  end

  @doc """
  Renders a native `<select>` element with shadcn styles.

  ## Example

      <.select name="timezone" value="utc">
        <:option value="utc" label="UTC" />
      </.select>
  """
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :placeholder, :string, default: "Choose an option"
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def select(assigns) do
    assigns =
      assign(assigns, :classes, [
        "border-input placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 dark:hover:bg-input/50 h-9 w-full min-w-0 appearance-none rounded-md border bg-transparent px-3 py-2 pr-9 text-sm shadow-xs transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive disabled:pointer-events-none disabled:cursor-not-allowed",
        assigns.class
      ])

    ~H"""
    <div
      data-slot="native-select-wrapper"
      class="group/native-select relative w-full has-[select:disabled]:opacity-50"
    >
      <select data-slot="native-select" name={@name} class={classes(@classes)} {@rest}>
        <option :if={is_nil(@value)} value="" disabled selected>{@placeholder}</option>
        <option :for={option <- @option} value={option.value} selected={@value == option.value}>
          {option.label}
        </option>
      </select>
      <span
        data-slot="native-select-icon"
        aria-hidden="true"
        class="text-muted-foreground pointer-events-none absolute top-1/2 right-3.5 size-4 -translate-y-1/2 opacity-50 select-none"
      >
        <CinderUI.Icons.icon name="chevron-down" class="size-4" aria-hidden="true" />
      </span>
    </div>
    """
  end

  @doc """
  Alias for `select/1` mirroring shadcn's `native-select` naming.
  """
  def native_select(assigns), do: select(assigns)

  @doc """
  Renders a radio group with native radio inputs.

  ## Example

      <.radio_group name="plan" value="pro">
        <:option value="free" label="Free" />
        <:option value="pro" label="Pro" />
      </.radio_group>
  """
  attr :name, :string, default: nil
  attr :value, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :option, required: true do
    attr :value, :string, required: true
    attr :label, :string, required: true
  end

  def radio_group(assigns) do
    assigns = assign(assigns, :classes, ["grid gap-3", assigns.class])

    ~H"""
    <div data-slot="radio-group" role="radiogroup" class={classes(@classes)}>
      <label :for={option <- @option} class="inline-flex items-center gap-2 text-sm">
        <input
          data-slot="radio-group-item"
          type="radio"
          name={@name}
          value={option.value}
          checked={@value == option.value}
          class="border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50"
          {@rest}
        />
        <span>{option.label}</span>
      </label>
    </div>
    """
  end

  @doc """
  Renders a slider using native range input(s).

  Use `min`, `max`, and `step` for scalar values. For range sliders, render two
  controls and sync values in LiveView.
  """
  attr :id, :string, default: nil
  attr :name, :string, default: nil
  attr :value, :integer, default: 0
  attr :min, :integer, default: 0
  attr :max, :integer, default: 100
  attr :step, :integer, default: 1
  attr :class, :string, default: nil
  attr :rest, :global

  def slider(assigns) do
    assigns =
      assign(assigns, :classes, [
        "accent-primary h-2 w-full cursor-pointer appearance-none rounded-full bg-primary/20",
        assigns.class
      ])

    ~H"""
    <input
      id={@id}
      data-slot="slider"
      type="range"
      name={@name}
      value={@value}
      min={@min}
      max={@max}
      step={@step}
      class={classes(@classes)}
      {@rest}
    />
    """
  end

  @doc """
  Wraps an input and sibling controls (buttons/icons) in a single inline group.

  ## Example

      <.input_group>
        <.input placeholder="Search" />
        <.button size={:sm}>Go</.button>
      </.input_group>
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def input_group(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex h-9 w-full items-stretch rounded-md border border-input bg-transparent shadow-xs transition-[color,box-shadow]",
        "has-[:focus-visible]:border-ring has-[:focus-visible]:ring-ring/50 has-[:focus-visible]:ring-[3px]",
        "[&>*]:relative [&>*]:h-full [&>*]:focus-visible:z-10",
        "[&>*:first-child]:rounded-l-md [&>*:last-child]:rounded-r-md",
        "[&>*:not(:last-child)]:border-r [&>*:not(:last-child)]:border-input",
        "[&>[data-slot=input]]:h-full [&>[data-slot=input]]:rounded-none [&>[data-slot=input]]:border-0 [&>[data-slot=input]]:bg-transparent [&>[data-slot=input]]:shadow-none [&>[data-slot=input]]:focus-visible:ring-0",
        "[&>[data-slot=button]]:h-full [&>[data-slot=button]]:rounded-none [&>[data-slot=button]]:border-0 [&>[data-slot=button]]:shadow-none [&>[data-slot=button]]:focus-visible:ring-0",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-group" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders an OTP-style segmented input layout.

  This component renders one input per position and can be wired using standard
  Phoenix input names such as `code[]`.
  """
  attr :name, :string, default: "code[]"
  attr :length, :integer, default: 6
  attr :values, :list, default: []
  attr :class, :string, default: nil
  attr :input_class, :string, default: nil
  attr :rest, :global

  def input_otp(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex items-center gap-2",
        assigns.class
      ])

    ~H"""
    <div data-slot="input-otp" class={classes(@classes)}>
      <input
        :for={index <- Enum.to_list(0..(@length - 1))}
        type="text"
        inputmode="numeric"
        pattern="[0-9]*"
        maxlength="1"
        name={@name}
        value={Enum.at(@values, index, "")}
        class={
          classes([
            "border-input focus-visible:border-ring focus-visible:ring-ring/50 h-10 w-10 rounded-md border bg-transparent text-center text-sm shadow-xs outline-none focus-visible:ring-[3px]",
            @input_class
          ])
        }
        {@rest}
      />
    </div>
    """
  end
end
