defmodule CinderUI.Components.Navigation do
  @moduledoc """
  Navigation components aligned with shadcn structures.

  Included:

  - Breadcrumb family (`breadcrumb/1`, `breadcrumb_list/1`, `breadcrumb_item/1`, `breadcrumb_link/1`, `breadcrumb_page/1`, `breadcrumb_separator/1`, `breadcrumb_ellipsis/1`)
  - Pagination family (`pagination/1`, `pagination_content/1`, `pagination_item/1`, `pagination_link/1`, `pagination_previous/1`, `pagination_next/1`, `pagination_ellipsis/1`)
  - `tabs/1`
  - `navigation_menu/1`
  """

  use Phoenix.Component

  import CinderUI.Classes

  @doc """
  Breadcrumb nav wrapper.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def breadcrumb(assigns) do
    assigns = assign(assigns, :classes, [assigns.class])

    ~H"""
    <nav data-slot="breadcrumb" aria-label="breadcrumb" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc """
  Breadcrumb list (`ol`).
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def breadcrumb_list(assigns) do
    assigns =
      assign(assigns, :classes, [
        "text-muted-foreground flex flex-wrap items-center gap-1.5 text-sm break-words sm:gap-2.5",
        assigns.class
      ])

    ~H"""
    <ol data-slot="breadcrumb-list" class={classes(@classes)}>{render_slot(@inner_block)}</ol>
    """
  end

  @doc """
  Breadcrumb item (`li`).
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def breadcrumb_item(assigns) do
    assigns = assign(assigns, :classes, ["inline-flex items-center gap-1.5", assigns.class])

    ~H"""
    <li data-slot="breadcrumb-item" class={classes(@classes)}>{render_slot(@inner_block)}</li>
    """
  end

  @doc """
  Breadcrumb link.
  """
  attr :href, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def breadcrumb_link(assigns) do
    assigns =
      assign(assigns, :classes, ["hover:text-foreground transition-colors", assigns.class])

    ~H"""
    <a data-slot="breadcrumb-link" href={@href} class={classes(@classes)} {@rest}>
      {render_slot(@inner_block)}
    </a>
    """
  end

  @doc """
  Breadcrumb current page item.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def breadcrumb_page(assigns) do
    assigns = assign(assigns, :classes, ["text-foreground font-normal", assigns.class])

    ~H"""
    <span
      data-slot="breadcrumb-page"
      role="link"
      aria-disabled="true"
      aria-current="page"
      class={classes(@classes)}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Breadcrumb separator item.
  """
  attr :class, :string, default: nil
  slot :inner_block

  def breadcrumb_separator(assigns) do
    assigns = assign(assigns, :classes, ["[&>svg]:size-3.5", assigns.class])

    ~H"""
    <li
      data-slot="breadcrumb-separator"
      role="presentation"
      aria-hidden="true"
      class={classes(@classes)}
    >
      <%= if @inner_block == [] do %>
        /
      <% else %>
        {render_slot(@inner_block)}
      <% end %>
    </li>
    """
  end

  @doc """
  Breadcrumb ellipsis element.
  """
  attr :class, :string, default: nil

  def breadcrumb_ellipsis(assigns) do
    assigns =
      assign(assigns, :classes, ["flex size-9 items-center justify-center", assigns.class])

    ~H"""
    <span
      data-slot="breadcrumb-ellipsis"
      role="presentation"
      aria-hidden="true"
      class={classes(@classes)}
    >
      …
    </span>
    """
  end

  @doc """
  Pagination nav wrapper.
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def pagination(assigns) do
    assigns = assign(assigns, :classes, ["mx-auto flex w-full justify-center", assigns.class])

    ~H"""
    <nav data-slot="pagination" role="navigation" aria-label="pagination" class={classes(@classes)}>
      {render_slot(@inner_block)}
    </nav>
    """
  end

  @doc """
  Pagination list wrapper (`ul`).
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def pagination_content(assigns) do
    assigns = assign(assigns, :classes, ["flex flex-row items-center gap-1", assigns.class])

    ~H"""
    <ul data-slot="pagination-content" class={classes(@classes)}>{render_slot(@inner_block)}</ul>
    """
  end

  @doc """
  Pagination item (`li`).
  """
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def pagination_item(assigns) do
    assigns = assign(assigns, :classes, [assigns.class])

    ~H"""
    <li data-slot="pagination-item" class={classes(@classes)}>{render_slot(@inner_block)}</li>
    """
  end

  @doc """
  Pagination link with active state.
  """
  attr :href, :string, default: nil
  attr :active, :boolean, default: false
  attr :size, :atom, default: :icon, values: [:default, :sm, :lg, :icon]
  attr :class, :string, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def pagination_link(assigns) do
    button_variant = if(assigns.active, do: :outline, else: :ghost)

    size_class =
      case assigns.size do
        :default -> "h-9 px-4 py-2"
        :sm -> "h-8 px-3 text-xs"
        :lg -> "h-10 px-6"
        :icon -> "size-9"
      end

    variant_class =
      case button_variant do
        :outline -> "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground"
        :ghost -> "hover:bg-accent hover:text-accent-foreground"
      end

    assigns =
      assign(assigns, :classes, [
        "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all disabled:pointer-events-none disabled:opacity-50 outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        size_class,
        variant_class,
        assigns.class
      ])

    ~H"""
    <a
      data-slot="pagination-link"
      data-active={@active}
      href={@href}
      aria-current={if(@active, do: "page", else: nil)}
      class={classes(@classes)}
      {@rest}
    >
      {render_slot(@inner_block)}
    </a>
    """
  end

  @doc """
  Previous-page shortcut link.
  """
  attr :href, :string, default: nil
  attr :class, :string, default: nil

  def pagination_previous(assigns) do
    assigns = assign(assigns, :classes, ["gap-1 px-2.5 sm:pl-2.5", assigns.class])

    ~H"""
    <.pagination_link
      href={@href}
      size={:default}
      class={classes(@classes)}
      aria-label="Go to previous page"
    >
      <span aria-hidden="true">←</span>
      <span class="hidden sm:block">Previous</span>
    </.pagination_link>
    """
  end

  @doc """
  Next-page shortcut link.
  """
  attr :href, :string, default: nil
  attr :class, :string, default: nil

  def pagination_next(assigns) do
    assigns = assign(assigns, :classes, ["gap-1 px-2.5 sm:pr-2.5", assigns.class])

    ~H"""
    <.pagination_link
      href={@href}
      size={:default}
      class={classes(@classes)}
      aria-label="Go to next page"
    >
      <span class="hidden sm:block">Next</span>
      <span aria-hidden="true">→</span>
    </.pagination_link>
    """
  end

  @doc """
  Pagination ellipsis marker.
  """
  attr :class, :string, default: nil

  def pagination_ellipsis(assigns) do
    assigns =
      assign(assigns, :classes, ["flex size-9 items-center justify-center", assigns.class])

    ~H"""
    <span data-slot="pagination-ellipsis" aria-hidden="true" class={classes(@classes)}>
      … <span class="sr-only">More pages</span>
    </span>
    """
  end

  @doc """
  Tab container with trigger and content slots.

  State is controlled through the `value` assign.
  """
  attr :value, :string, required: true
  attr :orientation, :atom, default: :horizontal, values: [:horizontal, :vertical]
  attr :variant, :atom, default: :default, values: [:default, :line]
  attr :class, :string, default: nil

  slot :trigger, required: true do
    attr :value, :string, required: true
  end

  slot :content, required: true do
    attr :value, :string, required: true
  end

  def tabs(assigns) do
    root_orientation = if(assigns.orientation == :horizontal, do: "flex-col", else: "flex-row")

    list_variant =
      if(assigns.variant == :default, do: "bg-muted", else: "gap-1 bg-transparent rounded-none")

    assigns =
      assigns
      |> assign(:root_classes, ["group/tabs flex gap-2", root_orientation, assigns.class])
      |> assign(:list_classes, [
        "rounded-lg p-[3px] text-muted-foreground inline-flex w-fit items-center justify-center",
        assigns.orientation == :vertical && "h-fit flex-col",
        assigns.orientation == :horizontal && "h-9",
        list_variant
      ])

    ~H"""
    <div data-slot="tabs" data-orientation={@orientation} class={classes(@root_classes)}>
      <div data-slot="tabs-list" data-variant={@variant} class={classes(@list_classes)}>
        <button
          :for={trigger <- @trigger}
          data-slot="tabs-trigger"
          data-state={if(trigger.value == @value, do: "active", else: "inactive")}
          type="button"
          class={
            classes([
              "text-foreground/60 hover:text-foreground relative inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5 rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap transition-all disabled:pointer-events-none disabled:opacity-50",
              @variant == :default && trigger.value == @value &&
                "bg-background text-foreground shadow-sm",
              @variant == :line && trigger.value == @value &&
                "text-foreground after:absolute after:inset-x-0 after:bottom-[-5px] after:h-0.5 after:bg-foreground"
            ])
          }
        >
          {render_slot(trigger)}
        </button>
      </div>

      <div
        :for={content <- @content}
        data-slot="tabs-content"
        data-state={if(content.value == @value, do: "active", else: "inactive")}
        class={classes(["flex-1 outline-none", content.value != @value && "hidden"])}
      >
        {render_slot(content)}
      </div>
    </div>
    """
  end

  @doc """
  Navigation menu scaffold.

  This is a semantic wrapper for custom menu items.
  """
  attr :class, :string, default: nil

  slot :item, required: true do
    attr :href, :string
    attr :active, :boolean
  end

  def navigation_menu(assigns) do
    assigns = assign(assigns, :classes, ["flex items-center gap-1", assigns.class])

    ~H"""
    <nav data-slot="navigation-menu" class={classes(@classes)}>
      <a
        :for={item <- @item}
        data-slot="navigation-menu-link"
        href={item[:href]}
        data-active={item[:active]}
        class={
          classes([
            "inline-flex h-9 items-center justify-center rounded-md px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground",
            item[:active] && "bg-accent text-accent-foreground"
          ])
        }
      >
        {render_slot(item)}
      </a>
    </nav>
    """
  end
end
