defmodule CinderUI.Helpers do
  @moduledoc false

  use Phoenix.Component

  import CinderUI.Classes

  # Internal helpers shared across CinderUI component modules.

  @doc """
  Returns true if the given map (typically a slot item or assigns) contains
  any link-related attribute (`href`, `navigate`, or `patch`).
  """
  def link?(map) do
    !!(map[:href] || map[:navigate] || map[:patch])
  end

  attr :item, :map, required: true
  attr :data_slot, :string, required: true
  attr :class, :any, required: true
  attr :role, :string, default: nil
  attr :rest, :global, include: ~w(aria-current aria-disabled)
  slot :inner_block, required: true

  def action_item(assigns) do
    assigns =
      assigns
      |> assign(:is_link, link?(assigns.item))
      |> assign(:link_classes, [
        assigns.class,
        assigns.item[:disabled] && "pointer-events-none opacity-50"
      ])
      |> assign(:button_classes, [
        assigns.class,
        "disabled:pointer-events-none disabled:opacity-50"
      ])
      |> assign(:link_attrs, action_item_link_attrs(assigns.item))
      |> assign(:button_attrs, action_item_button_attrs(assigns.item))

    ~H"""
    <.link
      :if={@is_link}
      data-slot={@data_slot}
      role={@role}
      class={classes(@link_classes)}
      {@link_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>

    <button
      :if={!@is_link}
      type="button"
      data-slot={@data_slot}
      role={@role}
      class={classes(@button_classes)}
      {@button_attrs}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp action_item_link_attrs(item) do
    item
    |> maybe_put_attr(:href)
    |> maybe_put_attr(:navigate)
    |> maybe_put_attr(:patch)
    |> maybe_put_attr(:method)
    |> maybe_put_attr(:replace)
    |> maybe_put_attr(:csrf_token)
  end

  defp action_item_button_attrs(item) do
    %{}
    |> maybe_put_attr(:disabled, item[:disabled])
  end

  defp maybe_put_attr(attrs, key), do: maybe_put_attr(attrs, key, attrs[key])

  defp maybe_put_attr(attrs, _key, nil), do: attrs
  defp maybe_put_attr(attrs, _key, false), do: attrs
  defp maybe_put_attr(attrs, key, value), do: Map.put(attrs, key, value)
end
