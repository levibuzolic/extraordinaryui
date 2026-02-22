defmodule Storybook.Components.Navigation do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Navigation.breadcrumb/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Navigation,
       [
         breadcrumb_list: 1,
         breadcrumb_item: 1,
         breadcrumb_link: 1,
         breadcrumb_separator: 1,
         breadcrumb_page: 1,
         pagination: 1,
         pagination_content: 1,
         pagination_item: 1,
         pagination_previous: 1,
         pagination_next: 1,
         pagination_link: 1,
         tabs: 1
       ]}
    ]

  def variations do
    [
      %Variation{
        id: :breadcrumb,
        template: """
        <.breadcrumb>
          <.breadcrumb_list>
            <.breadcrumb_item>
              <.breadcrumb_link href=\"#\">Home</.breadcrumb_link>
            </.breadcrumb_item>
            <.breadcrumb_separator />
            <.breadcrumb_item>
              <.breadcrumb_page>Dashboard</.breadcrumb_page>
            </.breadcrumb_item>
          </.breadcrumb_list>
        </.breadcrumb>
        """
      },
      %Variation{
        id: :pagination,
        template: """
        <.pagination>
          <.pagination_content>
            <.pagination_item><.pagination_previous href=\"#\" /></.pagination_item>
            <.pagination_item><.pagination_link href=\"#\" active={true}>1</.pagination_link></.pagination_item>
            <.pagination_item><.pagination_link href=\"#\">2</.pagination_link></.pagination_item>
            <.pagination_item><.pagination_next href=\"#\" /></.pagination_item>
          </.pagination_content>
        </.pagination>
        """
      },
      %Variation{
        id: :tabs,
        template: """
        <.tabs value=\"overview\">
          <:trigger value=\"overview\">Overview</:trigger>
          <:trigger value=\"settings\">Settings</:trigger>
          <:content value=\"overview\">Overview content</:content>
          <:content value=\"settings\">Settings content</:content>
        </.tabs>
        """
      }
    ]
  end
end
