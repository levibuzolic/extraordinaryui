defmodule Storybook.Components.Layout do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Layout.card/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Layout,
       [
         card_header: 1,
         card_title: 1,
         card_description: 1,
         card_content: 1,
         card_footer: 1,
         skeleton: 1,
         separator: 1,
         kbd: 1,
         aspect_ratio: 1
       ]}
    ]

  def variations do
    [
      %Variation{
        id: :card,
        template: """
        <.card>
          <.card_header>
            <.card_title>Project Setup</.card_title>
            <.card_description>Deploy your first environment.</.card_description>
          </.card_header>
          <.card_content>
            <p class=\"text-sm text-muted-foreground\">Configuration and credentials go here.</p>
          </.card_content>
          <.card_footer>
            <span class=\"text-sm\">Updated 1 minute ago</span>
          </.card_footer>
        </.card>
        """
      },
      %Variation{
        id: :skeleton_separator,
        template: """
        <div class=\"grid gap-3\">
          <.skeleton class=\"h-4 w-40\" />
          <.skeleton class=\"h-4 w-72\" />
          <.separator />
          <.kbd>⌘K</.kbd>
        </div>
        """
      },
      %Variation{
        id: :aspect_ratio,
        template: """
        <.aspect_ratio ratio=\"16 / 9\" class=\"rounded-md border\">
          <div class=\"flex h-full w-full items-center justify-center bg-muted text-muted-foreground\">16:9 content</div>
        </.aspect_ratio>
        """
      }
    ]
  end
end
