defmodule Storybook.Components.Overlay do
  use PhoenixStorybook.Story, :component

  def function, do: &CinderUI.Components.Overlay.dialog/1

  def imports,
    do: [
      {CinderUI.Components.Overlay,
       [popover: 1, tooltip: 1, hover_card: 1, dropdown_menu: 1, drawer: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :dialog,
        attributes: %{id: "demo-dialog", open: true},
        slots: ["Body"],
        template: """
        <.dialog id=\"demo-dialog\" open={true}>
          <:trigger><button class=\"rounded-md border px-3 py-2\">Open dialog</button></:trigger>
          <:title>Dialog title</:title>
          <:description>Dialog description.</:description>
          Modal body
          <:footer><button class=\"rounded-md border px-3 py-2\">Close</button></:footer>
        </.dialog>
        """
      },
      %Variation{
        id: :popover_tooltip,
        template: """
        <div class=\"flex items-center gap-6\">
          <.popover id="demo-popover">
            <:trigger><button class=\"rounded-md border px-3 py-2\">Popover</button></:trigger>
            <:content>Popover content</:content>
          </.popover>
          <.tooltip text=\"Tooltip text\">
            <button class=\"rounded-md border px-3 py-2\">Hover me</button>
          </.tooltip>
        </div>
        """
      },
      %Variation{
        id: :dropdown_drawer_hover_card,
        template: """
        <div class=\"grid gap-6\">
          <.dropdown_menu id="demo-dropdown">
            <:trigger><button class=\"rounded-md border px-3 py-2\">Actions</button></:trigger>
            <:item href=\"#\">Settings</:item>
            <:item href=\"#\">Billing</:item>
          </.dropdown_menu>

          <.drawer id=\"demo-drawer\" open={true} side={:right}>
            <:trigger><button class=\"rounded-md border px-3 py-2\">Open drawer</button></:trigger>
            <:title>Drawer</:title>
            Drawer content
          </.drawer>

          <.hover_card>
            <:trigger><button class=\"rounded-md border px-3 py-2\">Hover card</button></:trigger>
            <:content>Additional profile details.</:content>
          </.hover_card>
        </div>
        """
      }
    ]
  end
end
