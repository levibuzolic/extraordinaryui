defmodule Storybook.Components.Advanced do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Advanced.command/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Advanced,
       [item: 1, combobox: 1, calendar: 1, carousel: 1, chart: 1, sidebar: 1, sonner_toaster: 1]}
    ]

  def variations do
    [
      %Variation{
        id: :command,
        template: """
        <.command>
          <:group heading=\"General\">
            <.item>Profile</.item>
            <.item>Settings</.item>
          </:group>
        </.command>
        """
      },
      %Variation{
        id: :combobox_calendar,
        template: """
        <div class=\"grid gap-4\">
          <.combobox id=\"demo-combobox\" value=\"Pro\">
            <:option value=\"Free\" label=\"Free\" />
            <:option value=\"Pro\" label=\"Pro\" />
          </.combobox>
          <.calendar>
            <div class=\"p-4 text-sm text-muted-foreground\">Calendar integration point</div>
          </.calendar>
        </div>
        """
      },
      %Variation{
        id: :carousel_chart_sidebar_toaster,
        template: """
        <div class=\"grid gap-6\">
          <.carousel id=\"demo-carousel\">
            <:item><div class=\"h-32 rounded-md bg-muted\" /></:item>
            <:item><div class=\"h-32 rounded-md bg-muted/60\" /></:item>
          </.carousel>

          <.chart>
            <:title>Requests</:title>
            <:description>Last 24 hours</:description>
            <div class=\"h-24 rounded bg-muted\" />
          </.chart>

          <.sidebar>
            <:rail>
              <div class=\"space-y-2 text-sm\"><p>Dashboard</p><p>Settings</p></div>
            </:rail>
            <:inset>
              <div class=\"rounded bg-muted p-4\">Main content area</div>
            </:inset>
          </.sidebar>

          <.sonner_toaster position=\"bottom-right\" />
        </div>
        """
      }
    ]
  end
end
