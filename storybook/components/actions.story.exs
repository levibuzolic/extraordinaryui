defmodule Storybook.Components.Actions do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Actions.button/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Actions, [toggle: 1, button_group: 1]}
    ]

  def variations do
    [
      %Variation{id: :button_default, slots: ["Button"]},
      %Variation{id: :button_outline, attributes: %{variant: :outline}, slots: ["Outline"]},
      %Variation{
        id: :button_destructive,
        attributes: %{variant: :destructive},
        slots: ["Destructive"]
      },
      %Variation{
        id: :button_group,
        template: """
        <.button_group>
          <.button size={:sm}>Back</.button>
          <.button size={:sm}>Next</.button>
        </.button_group>
        """
      },
      %Variation{
        id: :toggle,
        template: """
        <.toggle pressed={true}>Toggle</.toggle>
        """
      }
    ]
  end
end
