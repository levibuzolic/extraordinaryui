defmodule Storybook.Root do
  use PhoenixStorybook.Index

  def folder_icon, do: {:fa, "wand-magic-sparkles", :light}

  def entry("components"), do: [name: "Components", icon: {:fa, "boxes-stacked", :light}]
end
