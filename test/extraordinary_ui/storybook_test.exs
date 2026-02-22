defmodule ExtraordinaryUI.StorybookTest do
  use ExUnit.Case, async: true

  alias ExtraordinaryUI.Storybook

  test "content_path points to bundled storybook directory" do
    path = Storybook.content_path()

    assert File.dir?(path)
    assert File.exists?(Path.join(path, "_root.index.exs"))
  end
end
