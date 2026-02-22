defmodule Storybook.Components.Forms do
  use PhoenixStorybook.Story, :component

  def function, do: &ExtraordinaryUI.Components.Forms.field/1

  def imports,
    do: [
      {ExtraordinaryUI.Components.Forms,
       [
         label: 1,
         input: 1,
         textarea: 1,
         checkbox: 1,
         switch: 1,
         select: 1,
         input_otp: 1,
         radio_group: 1
       ]}
    ]

  def variations do
    [
      %Variation{
        id: :field_with_input,
        template: """
        <.field>
          <:label><.label for=\"email\">Email</.label></:label>
          <.input id=\"email\" type=\"email\" placeholder=\"name@example.com\" />
          <:description>We never share your email.</:description>
        </.field>
        """
      },
      %Variation{
        id: :textarea,
        template: """
        <.field>
          <:label><.label for=\"bio\">Bio</.label></:label>
          <.textarea id=\"bio\" rows={4} placeholder=\"Tell us about yourself\" />
        </.field>
        """
      },
      %Variation{
        id: :checkbox_switch,
        template: """
        <div class=\"grid gap-3\">
          <.checkbox id=\"updates\" checked={true}>Product updates</.checkbox>
          <.switch id=\"beta\" checked={true}>Enable beta features</.switch>
        </div>
        """
      },
      %Variation{
        id: :select_radio_otp,
        template: """
        <div class=\"grid gap-4\">
          <.select name=\"plan\" value=\"pro\">
            <:option value=\"free\" label=\"Free\" />
            <:option value=\"pro\" label=\"Pro\" />
          </.select>
          <.radio_group name=\"team\" value=\"small\">
            <:option value=\"solo\" label=\"Solo\" />
            <:option value=\"small\" label=\"Small Team\" />
          </.radio_group>
          <.input_otp length={6} />
        </div>
        """
      }
    ]
  end
end
