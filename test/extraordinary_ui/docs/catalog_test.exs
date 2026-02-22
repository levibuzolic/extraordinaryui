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
        assert is_list(entry.examples)
        assert entry.examples != []
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
    assert button_entry.inline_doc_examples != []
    assert Enum.any?(button_entry.inline_doc_examples, &(&1.title == "Outline small action"))

    assert Enum.any?(
             button_entry.inline_doc_examples,
             &(&1.title == "Loading destructive action")
           )

    attribute_names = Enum.map(button_entry.attributes, & &1.name)
    assert "variant" in attribute_names
    assert "size" in attribute_names
    assert "inner_block" in Enum.map(button_entry.slots, & &1.name)
  end

  test "core families expose multiple complete generated examples" do
    entries = Catalog.sections() |> Enum.flat_map(& &1.entries)

    assert length(find_entry(entries, ExtraordinaryUI.Components.Actions, :button).examples) == 2
    assert length(find_entry(entries, ExtraordinaryUI.Components.Forms, :field).examples) == 2
    assert length(find_entry(entries, ExtraordinaryUI.Components.Feedback, :alert).examples) == 2

    assert length(
             find_entry(entries, ExtraordinaryUI.Components.DataDisplay, :accordion).examples
           ) == 2

    assert length(find_entry(entries, ExtraordinaryUI.Components.Navigation, :tabs).examples) == 2
    assert length(find_entry(entries, ExtraordinaryUI.Components.Overlay, :dialog).examples) == 2

    assert length(find_entry(entries, ExtraordinaryUI.Components.Advanced, :command).examples) ==
             2
  end

  test "composite components can expose multiple generated examples" do
    card_entry =
      Catalog.sections()
      |> Enum.flat_map(& &1.entries)
      |> Enum.find(fn entry ->
        entry.module == ExtraordinaryUI.Components.Layout and entry.function == :card
      end)

    assert card_entry
    assert length(card_entry.examples) == 2

    profile_example = Enum.find(card_entry.examples, &(&1.id == "profile"))
    pricing_example = Enum.find(card_entry.examples, &(&1.id == "pricing"))

    assert profile_example
    assert pricing_example
    assert profile_example.template_heex =~ "<.card_header>"
    assert pricing_example.template_heex =~ "<.card_footer>"
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

  defp find_entry(entries, module, function) do
    Enum.find(entries, fn entry -> entry.module == module and entry.function == function end)
  end
end
