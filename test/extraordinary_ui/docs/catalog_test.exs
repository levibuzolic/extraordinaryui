defmodule ExtraordinaryUI.Docs.CatalogTest do
  use ExUnit.Case, async: true

  alias ExtraordinaryUI.Docs.Catalog

  @modules [
    ExtraordinaryUI.Components.Actions,
    ExtraordinaryUI.Components.Forms,
    ExtraordinaryUI.Components.Layout,
    ExtraordinaryUI.Components.Feedback,
    ExtraordinaryUI.Components.DataDisplay,
    ExtraordinaryUI.Components.Navigation,
    ExtraordinaryUI.Components.Overlay,
    ExtraordinaryUI.Components.Advanced
  ]

  test "catalog includes all public component functions" do
    expected_count =
      @modules
      |> Enum.flat_map(fn module ->
        module
        |> Kernel.apply(:__info__, [:functions])
        |> Enum.filter(fn
          {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
          _ -> false
        end)
      end)
      |> length()

    assert Catalog.entry_count() == expected_count
  end

  test "all entries render without runtime render errors" do
    sections = Catalog.sections()

    assert sections != []

    Enum.each(sections, fn section ->
      assert section.entries != []

      Enum.each(section.entries, fn entry ->
        refute entry.preview_html =~ "Render error"
      end)
    end)
  end
end
