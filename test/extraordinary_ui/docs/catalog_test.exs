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
        assert entry.template_heex =~ "<."
        assert is_list(entry.attributes)
        assert is_list(entry.slots)
        assert entry.docs_path =~ "components/"
        assert entry.shadcn_url =~ "https://ui.shadcn.com/docs/components"
      end)
    end)
  end

  test "component metadata and shadcn reference are generated from definitions" do
    button_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == ExtraordinaryUI.Components.Actions and entry.function == :button
      end)

    assert button_entry
    assert button_entry.shadcn_slug == "button"
    assert button_entry.shadcn_url == "https://ui.shadcn.com/docs/components/button"

    attribute_names = Enum.map(button_entry.attributes, & &1.name)
    assert "variant" in attribute_names
    assert "size" in attribute_names
    assert "inner_block" in Enum.map(button_entry.slots, & &1.name)
  end

  test "avatar docs samples use base64 image data for realistic previews" do
    avatar_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == ExtraordinaryUI.Components.DataDisplay and entry.function == :avatar
      end)

    avatar_group_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == ExtraordinaryUI.Components.DataDisplay and entry.function == :avatar_group
      end)

    assert avatar_entry.preview_html =~ "data:image/svg+xml;base64,"
    assert avatar_group_entry.preview_html =~ "data:image/svg+xml;base64,"
    assert avatar_group_entry.template_heex =~ "<.avatar_group_count>"
  end
end
