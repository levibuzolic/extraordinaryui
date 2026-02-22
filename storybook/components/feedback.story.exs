defmodule Storybook.Components.Feedback do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Feedback.badge/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Feedback,
       [alert: 1, alert_title: 1, alert_description: 1, progress: 1, spinner: 1, empty_state: 1]}
    ]

  def variations do
    [
      %Variation{id: :badge, slots: ["New"]},
      %Variation{id: :badge_secondary, attributes: %{variant: :secondary}, slots: ["Beta"]},
      %Variation{
        id: :alert,
        template: """
        <.alert>
          <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\" class=\"size-4\"><path d=\"M12 2a10 10 0 100 20 10 10 0 000-20zm1 14h-2v-2h2v2zm0-4h-2V7h2v5z\" /></svg>
          <.alert_title>Heads up</.alert_title>
          <.alert_description>Deploy started successfully.</.alert_description>
        </.alert>
        """
      },
      %Variation{
        id: :progress_and_empty,
        template: """
        <div class=\"grid gap-4\">
          <.progress value={66} />
          <.empty_state>
            <:title>No alerts</:title>
            <:description>Everything looks healthy.</:description>
            <:action><.spinner class=\"size-5\" /></:action>
          </.empty_state>
        </div>
        """
      }
    ]
  end
end
