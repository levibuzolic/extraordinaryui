defmodule Storybook.Components.Root do
  use PhoenixStorybook.Index

  def folder_icon, do: {:fa, "cube", :light}

  def entry("actions"), do: [name: "Actions"]
  def entry("forms"), do: [name: "Forms"]
  def entry("layout"), do: [name: "Layout"]
  def entry("feedback"), do: [name: "Feedback"]
  def entry("data_display"), do: [name: "Data Display"]
  def entry("navigation"), do: [name: "Navigation"]
  def entry("overlay"), do: [name: "Overlay"]
  def entry("advanced"), do: [name: "Advanced"]
end
