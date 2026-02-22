defmodule Storybook.Components.DataDisplay do
  use PhoenixStorybook.Story, :component

  def function, do: &CinderUI.Components.DataDisplay.avatar/1

  def imports,
    do: [
      {CinderUI.Components.DataDisplay,
       [
         avatar_group: 1,
         avatar_group_count: 1,
         accordion: 1,
         table: 1,
         table_header: 1,
         table_body: 1,
         table_row: 1,
         table_head: 1,
         table_cell: 1
       ]}
    ]

  def variations do
    [
      %Variation{id: :avatar, attributes: %{alt: "Levi Noah"}},
      %Variation{
        id: :avatar_group,
        template: """
        <.avatar_group>
          <.avatar alt=\"Levi Noah\" />
          <.avatar alt=\"Marta Lee\" />
          <.avatar_group_count>+2</.avatar_group_count>
        </.avatar_group>
        """
      },
      %Variation{
        id: :accordion,
        template: """
        <.accordion>
          <:item title=\"What is Cinder UI?\" open={true}>A shadcn-inspired Phoenix component library.</:item>
          <:item title=\"Does it support theming?\">Yes, through CSS tokens and style presets.</:item>
        </.accordion>
        """
      },
      %Variation{
        id: :table,
        template: """
        <.table>
          <.table_header>
            <.table_row>
              <.table_head>Project</.table_head>
              <.table_head>Status</.table_head>
            </.table_row>
          </.table_header>
          <.table_body>
            <.table_row>
              <.table_cell>Web App</.table_cell>
              <.table_cell>Healthy</.table_cell>
            </.table_row>
            <.table_row>
              <.table_cell>Worker</.table_cell>
              <.table_cell>Pending</.table_cell>
            </.table_row>
          </.table_body>
        </.table>
        """
      }
    ]
  end
end
