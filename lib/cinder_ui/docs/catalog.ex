defmodule CinderUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix cinder_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias CinderUI.Components
  alias CinderUI.Components.Actions
  alias CinderUI.Components.Advanced
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Components.Overlay
  alias CinderUI.Icons
  alias Phoenix.HTML
  alias Phoenix.HTML.Safe

  @shadcn_base "https://ui.shadcn.com/docs/components"
  @grouped_shadcn_slugs %{
    "alert" => "alert",
    "avatar" => "avatar",
    "breadcrumb" => "breadcrumb",
    "button" => "button",
    "card" => "card",
    "input" => "input",
    "kbd" => "kbd",
    "pagination" => "pagination",
    "table" => "table",
    "toggle" => "toggle"
  }
  @shadcn_slug_overrides %{
    code_block: nil,
    empty_state: "empty",
    field: "form",
    icon: nil,
    input_otp: "input-otp",
    item: "command",
    menu: "navigation-menu",
    toast: "sonner",
    sonner_toaster: "sonner"
  }
  @avatar_data_levi "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGRlZnM+PGxpbmVhckdyYWRpZW50IGlkPSJnMSIgeDE9IjAiIHkxPSIwIiB4Mj0iMSIgeTI9IjEiPjxzdG9wIG9mZnNldD0iMCIgc3RvcC1jb2xvcj0iIzIyYzU1ZSIvPjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iIzA2YjZkNCIvPjwvbGluZWFyR3JhZGllbnQ+PC9kZWZzPjxyZWN0IHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgcng9IjQwIiBmaWxsPSJ1cmwoI2cxKSIvPjxjaXJjbGUgY3g9IjQwIiBjeT0iMzAiIHI9IjE0IiBmaWxsPSIjZWNmZWZmIiBmaWxsLW9wYWNpdHk9IjAuOSIvPjxwYXRoIGQ9Ik0xNiA2NmM0LTE0IDE2LTIyIDI0LTIyczIwIDggMjQgMjIiIGZpbGw9IiNlY2ZlZmYiIGZpbGwtb3BhY2l0eT0iMC45Ii8+PC9zdmc+"
  @avatar_data_ari "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGRlZnM+PGxpbmVhckdyYWRpZW50IGlkPSJnMiIgeDE9IjAiIHkxPSIwIiB4Mj0iMSIgeTI9IjEiPjxzdG9wIG9mZnNldD0iMCIgc3RvcC1jb2xvcj0iI2Y5NzMxNiIvPjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iI2UxMWQ0OCIvPjwvbGluZWFyR3JhZGllbnQ+PC9kZWZzPjxyZWN0IHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgcng9IjQwIiBmaWxsPSJ1cmwoI2cyKSIvPjxjaXJjbGUgY3g9IjQwIiBjeT0iMzAiIHI9IjE0IiBmaWxsPSIjZmZmMWYyIiBmaWxsLW9wYWNpdHk9IjAuOSIvPjxwYXRoIGQ9Ik0xNiA2NmM0LTE0IDE2LTIyIDI0LTIyczIwIDggMjQgMjIiIGZpbGw9IiNmZmYxZjIiIGZpbGwtb3BhY2l0eT0iMC45Ii8+PC9zdmc+"
  @avatar_data_noor "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA4MCA4MCI+PGRlZnM+PGxpbmVhckdyYWRpZW50IGlkPSJnMyIgeDE9IjAiIHkxPSIwIiB4Mj0iMSIgeTI9IjEiPjxzdG9wIG9mZnNldD0iMCIgc3RvcC1jb2xvcj0iIzYzNjZmMSIvPjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iIzhiNWNmNiIvPjwvbGluZWFyR3JhZGllbnQ+PC9kZWZzPjxyZWN0IHdpZHRoPSI4MCIgaGVpZ2h0PSI4MCIgcng9IjQwIiBmaWxsPSJ1cmwoI2czKSIvPjxjaXJjbGUgY3g9IjQwIiBjeT0iMzAiIHI9IjE0IiBmaWxsPSIjZWVmMmZmIiBmaWxsLW9wYWNpdHk9IjAuOSIvPjxwYXRoIGQ9Ik0xNiA2NmM0LTE0IDE2LTIyIDI0LTIyczIwIDggMjQgMjIiIGZpbGw9IiNlZWYyZmYiIGZpbGwtb3BhY2l0eT0iMC45Ii8+PC9zdmc+"

  @sections [
    %{id: "actions", title: "Actions", module: Actions},
    %{id: "forms", title: "Forms", module: Forms},
    %{id: "layout", title: "Layout", module: Layout},
    %{id: "icons", title: "Icons", module: Icons},
    %{id: "feedback", title: "Feedback", module: Feedback},
    %{id: "data-display", title: "Data Display", module: DataDisplay},
    %{id: "navigation", title: "Navigation", module: Navigation},
    %{id: "overlay", title: "Overlay", module: Overlay},
    %{id: "advanced", title: "Advanced", module: Advanced}
  ]

  @doc """
  Returns catalog sections and pre-rendered component entries.
  """
  @spec sections() :: [map()]
  def sections do
    Enum.map(@sections, fn section ->
      entries =
        section.module
        |> component_functions()
        |> Enum.map(&entry(section.module, &1))

      Map.put(section, :entries, entries)
    end)
  end

  @doc """
  Total number of component entries in the catalog.
  """
  @spec entry_count() :: non_neg_integer()
  def entry_count do
    sections()
    |> Enum.flat_map(& &1.entries)
    |> length()
  end

  @doc """
  Returns list of all component `{module, function}` pairs.
  """
  @spec functions() :: [{module(), atom()}]
  def functions do
    for section <- @sections,
        function <- component_functions(section.module),
        do: {section.module, function}
  end

  defp component_functions(module) do
    module
    |> Kernel.apply(:__info__, [:functions])
    |> Enum.filter(fn
      {name, 1} -> not String.starts_with?(Atom.to_string(name), "__")
      _ -> false
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  defp entry(module, function) do
    doc = function_doc(module, function)
    generated_examples = generated_examples(module, function)
    primary_example = List.first(generated_examples)
    inline_doc_examples = inline_doc_examples(doc)
    id = "#{module_slug(module)}-#{function}"
    slug = shadcn_slug(function)

    %{
      id: id,
      title: Atom.to_string(function),
      function: function,
      module: module,
      module_name: module |> Module.split() |> List.last(),
      docs: first_paragraph(doc),
      docs_full: doc,
      preview_html: primary_example.preview_html,
      template_heex: primary_example.template_heex,
      examples: generated_examples,
      inline_doc_examples: inline_doc_examples,
      attributes: component_attributes(module, function),
      slots: component_slots(module, function),
      source_line: component_line(module, function),
      shadcn_slug: slug,
      shadcn_url: shadcn_url(slug),
      docs_path: "components/#{id}.html"
    }
  end

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  defp function_doc(module, function) do
    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {{:function, ^function, 1}, _, _, %{"en" => doc}, _}
         when is_binary(doc) <- Enum.find(docs, &doc_entry?(&1, function)) do
      String.trim(doc)
    else
      _ -> "No documentation available."
    end
  end

  defp first_paragraph(doc) when is_binary(doc) do
    case doc |> String.split("\n\n") |> List.first() |> String.trim() do
      "" -> "No documentation available."
      paragraph -> paragraph
    end
  end

  defp doc_entry?({{:function, name, 1}, _, _, %{"en" => _}, _}, function), do: name == function
  defp doc_entry?(_, _function), do: false

  defp component_spec(module, function) do
    module
    |> Kernel.apply(:__components__, [])
    |> Map.get(function, %{attrs: [], slots: [], line: nil})
  end

  defp component_line(module, function), do: component_spec(module, function).line

  defp component_attributes(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:attrs, [])
    |> Enum.map(&normalize_attribute/1)
  end

  defp component_slots(module, function) do
    module
    |> component_spec(function)
    |> Map.get(:slots, [])
    |> Enum.map(&normalize_slot/1)
  end

  defp normalize_slot(slot) do
    %{
      name: Atom.to_string(slot.name),
      required: slot.required,
      attrs: slot.attrs |> Enum.map(&normalize_attribute/1)
    }
  end

  defp normalize_attribute(attr) do
    opts = Map.new(attr.opts)
    values = opts |> Map.get(:values, []) |> List.wrap()

    %{
      name: Atom.to_string(attr.name),
      type: inspect(attr.type),
      required: attr.required,
      default: Map.get(opts, :default),
      values: values,
      includes: opts |> Map.get(:include, []) |> List.wrap()
    }
  end

  defp shadcn_slug(function) do
    case Map.fetch(@shadcn_slug_overrides, function) do
      {:ok, slug} ->
        slug

      :error ->
        function
        |> Atom.to_string()
        |> slug_from_name()
    end
  end

  defp slug_from_name(name) do
    case String.split(name, "_", parts: 2) do
      [prefix, _rest] ->
        Map.get(@grouped_shadcn_slugs, prefix, String.replace(name, "_", "-"))

      _ ->
        String.replace(name, "_", "-")
    end
  end

  defp shadcn_url(nil), do: @shadcn_base
  defp shadcn_url(slug), do: "#{@shadcn_base}/#{slug}"

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  rescue
    exception ->
      escaped =
        Exception.format(:error, exception, __STACKTRACE__)
        |> HTML.html_escape()
        |> HTML.safe_to_string()

      "<pre class=\"text-destructive text-xs\">#{escaped}</pre>"
  end

  defp render_template(function, assigns) do
    assigns =
      assigns
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)

    {slot_entries, attr_entries} =
      Enum.split_with(assigns, fn {_key, value} -> slot_assign?(value) end)

    inner_slot =
      Enum.find_value(slot_entries, fn {key, value} -> if key == :inner_block, do: value end)

    named_slots =
      slot_entries
      |> Enum.reject(fn {key, _value} -> key == :inner_block end)
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.flat_map(fn {name, slot_values} ->
        Enum.map(slot_values, fn slot_value -> render_named_slot(name, slot_value) end)
      end)

    inner_block =
      inner_slot
      |> List.wrap()
      |> Enum.map(&slot_template_body/1)
      |> Enum.reject(&(&1 == ""))

    body = Enum.join(named_slots ++ inner_block, "\n\n")

    attrs =
      attr_entries
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.map(&render_attr/1)

    open_tag =
      case attrs do
        [] ->
          "<.#{function}"

        _ ->
          "<.#{function}\n" <> Enum.map_join(attrs, "\n", &"  #{&1}")
      end

    if body == "" do
      open_tag <> " />"
    else
      open_tag <> ">\n" <> indent_block(body, 2) <> "\n</.#{function}>"
    end
  end

  defp render_named_slot(name, slot_value) do
    attrs =
      slot_value
      |> Map.delete(:inner_block)
      |> Map.delete(:template)
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)
      |> Enum.sort_by(fn {key, _value} -> Atom.to_string(key) end)
      |> Enum.map(&render_attr/1)

    open_tag =
      case attrs do
        [] -> "<:#{name}>"
        _ -> "<:#{name} " <> Enum.join(attrs, " ") <> ">"
      end

    content = slot_template_body(slot_value)

    if content == "" do
      open_tag <> "</:#{name}>"
    else
      open_tag <> "\n" <> indent_block(content, 2) <> "\n</:#{name}>"
    end
  end

  defp render_attr({key, value}) do
    key = Atom.to_string(key)

    case value do
      value when is_binary(value) ->
        ~s(#{key}=#{inspect(value)})

      value when is_boolean(value) ->
        ~s(#{key}={#{value}})

      value when is_integer(value) or is_float(value) ->
        ~s(#{key}={#{value}})

      value when is_atom(value) ->
        ~s(#{key}={#{inspect(value)}})

      value when is_list(value) or is_map(value) ->
        ~s(#{key}={#{inspect(value, pretty: true, limit: :infinity)}})

      value ->
        ~s(#{key}={#{inspect(value)}})
    end
  end

  defp slot_assign?(value) do
    is_list(value) and value != [] and
      Enum.all?(value, fn
        %{inner_block: inner_block} when is_function(inner_block, 2) -> true
        _ -> false
      end)
  end

  defp slot_body(%{inner_block: inner_block}) do
    inner_block
    |> Kernel.apply([%{}, nil])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
    |> String.trim()
  rescue
    _ -> ""
  end

  defp slot_template_body(%{template: template}) when is_binary(template),
    do: String.trim(template)

  defp slot_template_body(slot_value), do: slot_body(slot_value)

  defp indent_block(content, spaces) do
    indentation = String.duplicate(" ", spaces)

    content
    |> String.split("\n")
    |> Enum.map_join("\n", &(indentation <> &1))
  end

  defp generated_examples(module, function) do
    module
    |> sample_examples(function)
    |> Enum.with_index(1)
    |> Enum.map(fn {example, index} ->
      assigns = example.assigns

      %{
        id: normalize_example_id(example[:id], index),
        title: example[:title] || default_example_title(index),
        description: example[:description],
        preview_html: render_component(module, function, assigns),
        template_heex: render_template(function, assigns)
      }
    end)
  end

  defp default_example_title(1), do: "Default"
  defp default_example_title(index), do: "Example #{index}"

  defp normalize_example_id(nil, index), do: "example-#{index}"

  defp normalize_example_id(id, index) do
    id
    |> to_string()
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
    |> String.trim("-")
    |> case do
      "" -> "example-#{index}"
      value -> value
    end
  end

  defp inline_doc_examples(doc) do
    fenced_examples =
      doc
      |> String.trim()
      |> then(&Regex.scan(~r/```([^\n]*)\n(.*?)```/s, &1, capture: :all_but_first))
      |> Enum.map(fn [info, code] ->
        {lang, title} = parse_fence_info(info)
        {lang, title, String.trim(code)}
      end)
      |> Enum.filter(fn {lang, _title, code} ->
        code != "" and (lang in ["", "heex", "html", "elixir"] and String.contains?(code, "<."))
      end)

    indented_examples =
      doc
      |> String.split("\n")
      |> Enum.chunk_by(&String.starts_with?(&1, "    "))
      |> Enum.filter(fn
        [line | _] -> String.starts_with?(line, "    ")
        _ -> false
      end)
      |> Enum.map(fn chunk ->
        chunk
        |> Enum.map_join("\n", &String.trim_leading(&1, "    "))
        |> String.trim()
      end)
      |> Enum.filter(&String.contains?(&1, "<."))
      |> Enum.map(&{"", nil, &1})

    (fenced_examples ++ indented_examples)
    |> Enum.uniq()
    |> Enum.with_index(1)
    |> Enum.map(fn {{lang, title, code}, index} ->
      %{
        id: "inline-#{index}",
        title: inline_doc_example_title(title, lang, index),
        template_heex: code
      }
    end)
  end

  defp parse_fence_info(info) do
    trimmed = String.trim(info)
    title = fence_title(trimmed)

    case String.split(trimmed, ~r/\s+/, trim: true) do
      [] ->
        {"", title}

      [lang | rest] ->
        fallback_title =
          case Enum.reject(rest, &String.contains?(&1, "=")) do
            [] -> nil
            tokens -> Enum.join(tokens, " ")
          end

        {String.downcase(lang), title || fallback_title}
    end
  end

  defp fence_title(info) do
    case Regex.run(~r/title\s*=\s*"([^"]+)"/, info, capture: :all_but_first) do
      [title] ->
        title

      _ ->
        case Regex.run(~r/title\s*=\s*'([^']+)'/, info, capture: :all_but_first) do
          [title] -> title
          _ -> nil
        end
    end
  end

  defp inline_doc_example_title(nil, "", index), do: "Inline docs example #{index}"
  defp inline_doc_example_title(nil, lang, index), do: "Inline docs example #{index} (#{lang})"
  defp inline_doc_example_title(title, _lang, _index), do: title

  defp sample_examples(Actions, :button) do
    [
      %{
        id: "primary",
        title: "Primary CTA",
        description: "Default shadcn call-to-action button",
        assigns: %{inner_block: slot("Create project")}
      },
      %{
        id: "destructive-loading",
        title: "Destructive Loading",
        description: "Destructive action with loading spinner",
        assigns: %{variant: :destructive, loading: true, inner_block: slot("Deleting...")}
      }
    ]
  end

  defp sample_examples(Forms, :field) do
    [
      %{
        id: "profile",
        title: "Profile Field",
        description: "Label, helper text, and input control",
        assigns: sample_assigns(Forms, :field)
      },
      %{
        id: "validation",
        title: "Validation State",
        description: "Field with inline validation error",
        assigns: field_validation_assigns()
      }
    ]
  end

  defp sample_examples(Feedback, :alert) do
    [
      %{
        id: "notice",
        title: "Notice Alert",
        description: "Default informational alert",
        assigns: sample_assigns(Feedback, :alert)
      },
      %{
        id: "destructive",
        title: "Destructive Alert",
        description: "Irreversible action warning style",
        assigns: destructive_alert_assigns()
      }
    ]
  end

  defp sample_examples(DataDisplay, :accordion) do
    [
      %{
        id: "faq",
        title: "FAQ Accordion",
        description: "Common questions with expanded first section",
        assigns: sample_assigns(DataDisplay, :accordion)
      },
      %{
        id: "release-notes",
        title: "Release Notes",
        description: "Changelog-focused accordion structure",
        assigns: release_notes_accordion_assigns()
      }
    ]
  end

  defp sample_examples(Navigation, :tabs) do
    [
      %{
        id: "default",
        title: "Default Tabs",
        description: "Segmented tab controls with content panels",
        assigns: sample_assigns(Navigation, :tabs)
      },
      %{
        id: "line",
        title: "Line Variant",
        description: "Line-style tabs for settings surfaces",
        assigns: line_tabs_assigns()
      }
    ]
  end

  defp sample_examples(Overlay, :dialog) do
    [
      %{
        id: "settings",
        title: "Settings Dialog",
        description: "Standard dialog with trigger, copy, and footer actions",
        assigns: sample_assigns(Overlay, :dialog)
      },
      %{
        id: "confirmation",
        title: "Confirmation Dialog",
        description: "Confirmation flow with cancel and destructive actions",
        assigns: destructive_dialog_assigns()
      }
    ]
  end

  defp sample_examples(Advanced, :command) do
    [
      %{
        id: "palette",
        title: "Command Palette",
        description: "Grouped quick actions and navigation items",
        assigns: command_palette_assigns()
      },
      %{
        id: "project-switcher",
        title: "Project Switcher",
        description: "Cross-project jump menu with grouped items",
        assigns: project_switcher_command_assigns()
      }
    ]
  end

  defp sample_examples(Layout, :card) do
    [
      %{
        id: "profile",
        title: "Profile Card",
        description: "Header, metadata, and footer actions",
        assigns: card_profile_assigns()
      },
      %{
        id: "pricing",
        title: "Pricing Card",
        description: "Pricing details with primary CTA",
        assigns: card_pricing_assigns()
      }
    ]
  end

  defp sample_examples(module, function) do
    assigns = sample_assigns(module, function)

    [
      %{id: "default", title: "Default", assigns: assigns},
      alternate_example(module, function, assigns)
    ]
  end

  defp alternate_example(Actions, :button_group, assigns) do
    %{
      id: "vertical",
      title: "Vertical Group",
      description: "Stacked actions similar to shadcn toolbar patterns",
      assigns: Map.put(assigns, :orientation, :vertical)
    }
  end

  defp alternate_example(Actions, :toggle, _assigns) do
    %{
      id: "outline",
      title: "Outline Small Toggle",
      description: "Compact outline treatment for dense controls",
      assigns: %{pressed: false, variant: :outline, size: :sm, inner_block: slot("Italic")}
    }
  end

  defp alternate_example(Actions, :toggle_group, _assigns) do
    toggle_l_html =
      render_component(Actions, :toggle, %{variant: :outline, size: :sm, inner_block: slot("L")})

    toggle_r_html =
      render_component(Actions, :toggle, %{variant: :outline, size: :sm, inner_block: slot("R")})

    %{
      id: "multiple-vertical",
      title: "Vertical Multi-select",
      description: "Multiple selection with vertical arrangement",
      assigns: %{
        type: :multiple,
        orientation: :vertical,
        inner_block:
          slot(
            toggle_l_html <> "\n" <> toggle_r_html,
            """
            <.toggle variant={:outline} size={:sm}>L</.toggle>
            <.toggle variant={:outline} size={:sm}>R</.toggle>
            """
          )
      }
    }
  end

  defp alternate_example(Forms, :checkbox, assigns) do
    %{
      id: "unchecked",
      title: "Unchecked",
      description: "Unselected state before user confirmation",
      assigns: Map.put(assigns, :checked, false)
    }
  end

  defp alternate_example(Forms, :input, _assigns) do
    %{
      id: "password",
      title: "Password Input",
      description: "Credential-style input with hidden value",
      assigns: %{id: "docs-input-password", type: "password", placeholder: "••••••••"}
    }
  end

  defp alternate_example(Forms, :input_group, _assigns) do
    input_html = render_component(Forms, :input, %{placeholder: "Filter by team..."})

    filter_button_html =
      render_component(Actions, :button, %{variant: :outline, inner_block: slot("Filter")})

    %{
      id: "filter",
      title: "Filter Group",
      description: "Search + action affordance inspired by docs toolbars",
      assigns: %{
        inner_block:
          slot(
            input_html <> "\n" <> filter_button_html,
            """
            <.input placeholder="Filter by team..." />
            <.button variant={:outline}>Filter</.button>
            """
          )
      }
    }
  end

  defp alternate_example(Forms, :input_otp, _assigns) do
    %{
      id: "partial",
      title: "Partially Entered",
      description: "OTP with incomplete values",
      assigns: %{name: "recovery_code[]", values: ["9", "4", "1", "", "", ""]}
    }
  end

  defp alternate_example(Forms, :radio_group, _assigns) do
    %{
      id: "plan-selection",
      title: "Plan Selection",
      description: "Alternative option set for billing choices",
      assigns: %{
        name: "plan-tier",
        value: "team",
        option: [
          %{value: "starter", label: "Starter"},
          %{value: "team", label: "Team"},
          %{value: "enterprise", label: "Enterprise"}
        ]
      }
    }
  end

  defp alternate_example(Forms, :select, _assigns) do
    %{
      id: "timezone",
      title: "Timezone Select",
      description: "A common settings form select",
      assigns: %{
        name: "timezone",
        value: "utc",
        option: [
          %{value: "utc", label: "UTC"},
          %{value: "pst", label: "Pacific (PST)"},
          %{value: "est", label: "Eastern (EST)"}
        ]
      }
    }
  end

  defp alternate_example(Forms, :slider, assigns) do
    %{
      id: "low-value",
      title: "Low Value",
      description: "Smaller progress point for subtle adjustments",
      assigns: Map.put(assigns, :value, 20)
    }
  end

  defp alternate_example(Forms, :switch, assigns) do
    %{
      id: "small-off",
      title: "Small Off",
      description: "Compact inactive switch state",
      assigns: assigns |> Map.put(:checked, false) |> Map.put(:size, :sm)
    }
  end

  defp alternate_example(Forms, :textarea, _assigns) do
    %{
      id: "longform",
      title: "Longform",
      description: "Expanded text area for release notes",
      assigns: %{
        id: "docs-textarea-notes",
        rows: 6,
        value: "Release notes draft:\n- API stabilization\n- docs refresh"
      }
    }
  end

  defp alternate_example(Layout, :aspect_ratio, _assigns) do
    %{
      id: "square",
      title: "Square Ratio",
      description: "1:1 media framing for avatars and tiles",
      assigns: %{
        ratio: "1 / 1",
        inner_block:
          slot(
            "<div class=\"flex h-full w-full items-center justify-center bg-muted text-xs text-muted-foreground\">1:1</div>"
          )
      }
    }
  end

  defp alternate_example(Layout, :kbd, _assigns) do
    %{
      id: "shift-enter",
      title: "Multi-key",
      description: "Compound shortcut glyph",
      assigns: %{inner_block: slot("Shift ↵")}
    }
  end

  defp alternate_example(Layout, :kbd_group, _assigns) do
    %{
      id: "open-command",
      title: "Command Group",
      description: "Grouped shortcut keys for command palette actions",
      assigns: %{inner_block: slot("<span>⌘</span><span>P</span>")}
    }
  end

  defp alternate_example(Layout, :resizable, _assigns) do
    %{
      id: "vertical",
      title: "Vertical Split",
      description: "Stacked panel arrangement",
      assigns: %{
        direction: :vertical,
        panel: [
          %{
            size: 50,
            inner_block: fn _, _ ->
              HTML.raw("<div class=\"rounded-md bg-muted p-2 text-xs\">Top panel</div>")
            end,
            template: "<div class=\"rounded-md bg-muted p-2 text-xs\">Top panel</div>"
          },
          %{
            size: 50,
            inner_block: fn _, _ ->
              HTML.raw("<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Bottom panel</div>")
            end,
            template: "<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Bottom panel</div>"
          }
        ]
      }
    }
  end

  defp alternate_example(Layout, :scroll_area, _assigns) do
    %{
      id: "taller",
      title: "Taller Viewport",
      description: "Expanded scroll region for longer content",
      assigns: %{
        class: "h-32 rounded-md border",
        inner_block:
          slot(
            Enum.map_join(1..12, "", fn index ->
              ~s(<div class="py-1 text-sm">Item #{index}</div>)
            end),
            Enum.map_join(1..12, "\n", fn index ->
              ~s(<div class="py-1 text-sm">Item #{index}</div>)
            end)
          )
      }
    }
  end

  defp alternate_example(Layout, :separator, assigns) do
    %{
      id: "vertical",
      title: "Vertical Separator",
      description: "Vertical divider between adjacent controls",
      assigns: assigns |> Map.put(:orientation, :vertical) |> Map.put(:class, "h-8")
    }
  end

  defp alternate_example(Layout, :skeleton, _assigns) do
    %{
      id: "card-line",
      title: "Card Skeleton Line",
      description: "Wider placeholder for card sections",
      assigns: %{class: "h-5 w-full max-w-xs"}
    }
  end

  defp alternate_example(Icons, :icon, _assigns) do
    %{
      id: "calendar",
      title: "Calendar Icon",
      description: "Alternate lucide glyph sample",
      assigns: %{name: "calendar-days", class: "size-5"}
    }
  end

  defp alternate_example(Feedback, :badge, _assigns) do
    %{
      id: "outline",
      title: "Outline Badge",
      description: "Subtle neutral badge for metadata",
      assigns: %{variant: :outline, inner_block: slot("Draft")}
    }
  end

  defp alternate_example(Feedback, :alert_description, _assigns) do
    %{
      id: "detailed",
      title: "Detailed Description",
      description: "Richer alert body copy",
      assigns: %{inner_block: slot("Last deploy finished in 1m 21s with zero errors.")}
    }
  end

  defp alternate_example(Feedback, :alert_title, _assigns) do
    %{
      id: "warning-title",
      title: "Warning Title",
      description: "Alternative alert headline",
      assigns: %{inner_block: slot("Action required")}
    }
  end

  defp alternate_example(Feedback, :progress, assigns) do
    %{
      id: "complete",
      title: "Near Complete",
      description: "High completion state for long-running tasks",
      assigns: Map.put(assigns, :value, 96)
    }
  end

  defp alternate_example(Feedback, :spinner, _assigns) do
    %{
      id: "large",
      title: "Large Spinner",
      description: "More prominent loading indicator",
      assigns: %{class: "size-6"}
    }
  end

  defp alternate_example(Feedback, :toast, _assigns) do
    destructive_item =
      render_component(Feedback, :toast_item, %{
        variant: :destructive,
        inner_block: slot("Deployment failed. Retry in a few seconds.")
      })

    %{
      id: "top-right",
      title: "Top Right Stack",
      description: "Pinned toast stack at the top edge",
      assigns: %{
        position: :top_right,
        class: "static z-0 w-full max-w-none p-0",
        inner_block:
          slot(
            destructive_item,
            """
            <.toast_item variant={:destructive}>Deployment failed. Retry in a few seconds.</.toast_item>
            """
          )
      }
    }
  end

  defp alternate_example(Feedback, :toast_item, _assigns) do
    %{
      id: "destructive",
      title: "Destructive Toast",
      description: "Error-state toast item variant",
      assigns: %{variant: :destructive, inner_block: slot("Build failed on production branch.")}
    }
  end

  defp alternate_example(Feedback, :empty_state, _assigns) do
    cta_html =
      render_component(Actions, :button, %{
        variant: :default,
        size: :sm,
        inner_block: slot("Create project")
      })

    %{
      id: "with-primary-cta",
      title: "Primary CTA",
      description: "Motivates next action with stronger hierarchy",
      assigns: %{
        title: slot("No active projects"),
        description: slot("Start by creating your first project workspace."),
        action: slot(cta_html, "<.button size={:sm}>Create project</.button>"),
        icon: slot("<span class=\"text-xl\">+</span>")
      }
    }
  end

  defp alternate_example(DataDisplay, :avatar, _assigns) do
    %{
      id: "fallback",
      title: "Fallback Initials",
      description: "Avatar without image source",
      assigns: %{alt: "Nina Hall", size: :lg}
    }
  end

  defp alternate_example(DataDisplay, :avatar_group, _assigns) do
    preview_html =
      [
        render_component(DataDisplay, :avatar, %{alt: "Jordan Miles", fallback: "JM"}),
        render_component(DataDisplay, :avatar, %{alt: "Sara Lo", fallback: "SL"}),
        render_component(DataDisplay, :avatar_group_count, %{inner_block: slot("+6")})
      ]
      |> Enum.join("\n")

    %{
      id: "fallback-group",
      title: "Fallback Group",
      description: "Group with initials and larger overflow count",
      assigns: %{
        inner_block:
          slot(
            preview_html,
            """
            <.avatar alt="Jordan Miles" fallback="JM" />
            <.avatar alt="Sara Lo" fallback="SL" />
            <.avatar_group_count>+6</.avatar_group_count>
            """
          )
      }
    }
  end

  defp alternate_example(DataDisplay, :avatar_group_count, _assigns) do
    %{
      id: "higher-count",
      title: "Higher Count",
      description: "Larger overflow quantity",
      assigns: %{inner_block: slot("+12")}
    }
  end

  defp alternate_example(DataDisplay, :code_block, _assigns) do
    %{
      id: "install-command",
      title: "Install Command",
      description: "CLI snippet variant",
      assigns: %{inner_block: slot("mix cinder_ui.install")}
    }
  end

  defp alternate_example(DataDisplay, :collapsible, assigns) do
    %{
      id: "closed",
      title: "Closed by Default",
      description: "Collapsed state until explicitly opened",
      assigns: assigns |> Map.put(:open, false) |> Map.put(:trigger, slot("Release details"))
    }
  end

  defp alternate_example(DataDisplay, :table_row, assigns) do
    %{
      id: "selected-row",
      title: "Selected Row",
      description: "Highlighted state for active row",
      assigns: Map.put(assigns, :state, "selected")
    }
  end

  defp alternate_example(Navigation, :breadcrumb, _assigns) do
    %{
      id: "with-ellipsis",
      title: "Collapsed Trail",
      description: "Long-path breadcrumb with ellipsis",
      assigns: %{
        inner_block:
          slot(
            """
            <ol data-slot=\"breadcrumb-list\" class=\"flex items-center gap-2\">
              <li data-slot=\"breadcrumb-item\"><a data-slot=\"breadcrumb-link\" href=\"#\">Home</a></li>
              <li data-slot=\"breadcrumb-separator\">/</li>
              <li data-slot=\"breadcrumb-item\"><span data-slot=\"breadcrumb-ellipsis\">…</span></li>
              <li data-slot=\"breadcrumb-separator\">/</li>
              <li data-slot=\"breadcrumb-item\"><span data-slot=\"breadcrumb-page\">Settings</span></li>
            </ol>
            """,
            """
            <.breadcrumb_list>
              <.breadcrumb_item><.breadcrumb_link href="#">Home</.breadcrumb_link></.breadcrumb_item>
              <.breadcrumb_separator>/</.breadcrumb_separator>
              <.breadcrumb_item><.breadcrumb_ellipsis /></.breadcrumb_item>
              <.breadcrumb_separator>/</.breadcrumb_separator>
              <.breadcrumb_item><.breadcrumb_page>Settings</.breadcrumb_page></.breadcrumb_item>
            </.breadcrumb_list>
            """
          )
      }
    }
  end

  defp alternate_example(Navigation, :breadcrumb_link, assigns) do
    %{
      id: "project-link",
      title: "Project Link",
      description: "Alternate breadcrumb target",
      assigns: assigns |> Map.put(:href, "/projects") |> Map.put(:inner_block, slot("Projects"))
    }
  end

  defp alternate_example(Navigation, :breadcrumb_page, _assigns) do
    %{
      id: "settings-page",
      title: "Settings Page",
      description: "Current page item for settings context",
      assigns: %{inner_block: slot("Settings")}
    }
  end

  defp alternate_example(Navigation, :breadcrumb_separator, _assigns) do
    %{
      id: "chevron",
      title: "Chevron Separator",
      description: "Chevron separator style",
      assigns: %{inner_block: slot(">")}
    }
  end

  defp alternate_example(Navigation, :menu, assigns) do
    %{
      id: "horizontal",
      title: "Horizontal Menu",
      description: "Top-nav style menu layout",
      assigns: Map.put(assigns, :orientation, :horizontal)
    }
  end

  defp alternate_example(Navigation, :navigation_menu, _assigns) do
    %{
      id: "docs-nav",
      title: "Docs Navigation",
      description: "Three-link navigation menu example",
      assigns: %{
        item: [
          %{href: "#", inner_block: fn _, _ -> "Components" end},
          %{href: "#", active: true, inner_block: fn _, _ -> "Examples" end},
          %{href: "#", inner_block: fn _, _ -> "Changelog" end}
        ]
      }
    }
  end

  defp alternate_example(Navigation, :pagination_link, assigns) do
    %{
      id: "inactive",
      title: "Inactive Link",
      description: "Default inactive pagination link",
      assigns: assigns |> Map.put(:active, false) |> Map.put(:inner_block, slot("3"))
    }
  end

  defp alternate_example(Navigation, :tabs, _assigns) do
    %{
      id: "vertical",
      title: "Vertical Tabs",
      description: "Sidebar-style tab orientation",
      assigns: %{
        value: "account",
        orientation: :vertical,
        trigger: [
          %{value: "account", inner_block: fn _, _ -> "Account" end},
          %{value: "security", inner_block: fn _, _ -> "Security" end}
        ],
        content: [
          %{value: "account", inner_block: fn _, _ -> "Account settings content" end},
          %{value: "security", inner_block: fn _, _ -> "Security settings content" end}
        ]
      }
    }
  end

  defp alternate_example(Overlay, :alert_dialog, _assigns) do
    trigger_html =
      render_component(Actions, :button, %{
        variant: :destructive,
        inner_block: slot("Delete user")
      })

    keep_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Keep")
      })

    remove_html =
      render_component(Actions, :button, %{
        variant: :destructive,
        size: :sm,
        inner_block: slot("Remove")
      })

    %{
      id: "destructive",
      title: "Destructive Alert Dialog",
      description: "Irreversible confirmation flow",
      assigns: %{
        id: "docs-alert-dialog-delete",
        open: false,
        trigger: slot(trigger_html, "<.button variant={:destructive}>Delete user</.button>"),
        title: slot("Delete this user?"),
        description: slot("This permanently removes profile data."),
        inner_block: slot("This action cannot be undone."),
        footer:
          slot(
            keep_html <> "\n" <> remove_html,
            """
            <.button variant={:outline} size={:sm}>Keep</.button>
            <.button variant={:destructive} size={:sm}>Remove</.button>
            """
          )
      }
    }
  end

  defp alternate_example(Overlay, :drawer, assigns) do
    %{
      id: "left-drawer",
      title: "Left Drawer",
      description: "Alternate entry side for navigation surfaces",
      assigns: Map.put(assigns, :side, :left)
    }
  end

  defp alternate_example(Overlay, :dropdown_menu, _assigns) do
    %{
      id: "mixed-items",
      title: "Mixed Action Menu",
      description: "Includes link and disabled action entries",
      assigns: %{
        id: "docs-dropdown-mixed",
        trigger: slot("Manage"),
        item: [
          %{href: "#", inner_block: fn _, _ -> "Open settings" end},
          %{inner_block: fn _, _ -> "Duplicate" end},
          %{inner_block: fn _, _ -> "Archive" end, disabled: true}
        ]
      }
    }
  end

  defp alternate_example(Overlay, :hover_card, _assigns) do
    %{
      id: "profile",
      title: "Profile Hover Card",
      description: "Profile summary preview on hover",
      assigns: %{
        trigger: slot("@levi"),
        content: slot("Maintainer · ships weekly docs and component updates.")
      }
    }
  end

  defp alternate_example(Overlay, :menubar, _assigns) do
    open_html =
      render_component(Actions, :button, %{
        variant: :ghost,
        size: :sm,
        class: "w-full justify-start",
        inner_block: slot("Open…")
      })

    export_html =
      render_component(Actions, :button, %{
        variant: :ghost,
        size: :sm,
        class: "w-full justify-start",
        inner_block: slot("Export")
      })

    %{
      id: "file-and-share",
      title: "Two Menus",
      description: "File and share menu groups",
      assigns: %{
        menu: [
          %{
            label: "File",
            inner_block: fn _, _ -> HTML.raw(open_html) end,
            template:
              "<.button variant={:ghost} size={:sm} class=\"w-full justify-start\">Open…</.button>"
          },
          %{
            label: "Share",
            inner_block: fn _, _ -> HTML.raw(export_html) end,
            template:
              "<.button variant={:ghost} size={:sm} class=\"w-full justify-start\">Export</.button>"
          }
        ]
      }
    }
  end

  defp alternate_example(Overlay, :popover, assigns) do
    %{
      id: "details",
      title: "Details Popover",
      description: "Contextual details popover",
      assigns:
        assigns
        |> Map.put(:trigger, slot("View details"))
        |> Map.put(:content, slot("Last deployment: 3 minutes ago"))
    }
  end

  defp alternate_example(Overlay, :sheet, assigns) do
    %{
      id: "bottom-sheet",
      title: "Bottom Sheet",
      description: "Mobile-oriented sheet placement",
      assigns: Map.put(assigns, :side, :bottom)
    }
  end

  defp alternate_example(Overlay, :tooltip, _assigns) do
    button_html =
      render_component(Actions, :button, %{
        variant: :ghost,
        size: :sm,
        inner_block: slot("Need help?")
      })

    %{
      id: "help-tooltip",
      title: "Help Tooltip",
      description: "Assistive copy on hover/focus",
      assigns: %{
        text: "You can edit this setting later.",
        inner_block:
          slot(
            button_html,
            """
            <.button variant={:ghost} size={:sm}>Need help?</.button>
            """
          )
      }
    }
  end

  defp alternate_example(Advanced, :calendar, _assigns) do
    %{
      id: "month-grid",
      title: "Month Grid Shell",
      description: "Calendar scaffold with placeholder grid",
      assigns: %{
        inner_block:
          slot(
            "<div class=\"grid grid-cols-7 gap-1 text-center text-xs text-muted-foreground\"><span>Su</span><span>Mo</span><span>Tu</span><span>We</span><span>Th</span><span>Fr</span><span>Sa</span></div>"
          )
      }
    }
  end

  defp alternate_example(Advanced, :carousel, _assigns) do
    %{
      id: "three-slides",
      title: "Three Slides",
      description: "Additional slide for onboarding tour",
      assigns: %{
        id: "docs-carousel-tour",
        item: [
          %{
            inner_block: fn _, _ ->
              HTML.raw("<div class=\"h-24 rounded-md bg-muted p-4 text-xs\">Step 1</div>")
            end,
            template: "<div class=\"h-24 rounded-md bg-muted p-4 text-xs\">Step 1</div>"
          },
          %{
            inner_block: fn _, _ ->
              HTML.raw("<div class=\"h-24 rounded-md bg-muted/70 p-4 text-xs\">Step 2</div>")
            end,
            template: "<div class=\"h-24 rounded-md bg-muted/70 p-4 text-xs\">Step 2</div>"
          },
          %{
            inner_block: fn _, _ ->
              HTML.raw("<div class=\"h-24 rounded-md bg-muted/40 p-4 text-xs\">Step 3</div>")
            end,
            template: "<div class=\"h-24 rounded-md bg-muted/40 p-4 text-xs\">Step 3</div>"
          }
        ]
      }
    }
  end

  defp alternate_example(Advanced, :chart, _assigns) do
    %{
      id: "weekly-signups",
      title: "Weekly Signups",
      description: "Alternative chart frame metadata",
      assigns: %{
        title: slot("Signups"),
        description: slot("Last 7 days"),
        inner_block:
          slot(
            "<div class=\"h-24 rounded bg-muted p-2 text-xs text-muted-foreground\">Chart placeholder</div>"
          )
      }
    }
  end

  defp alternate_example(Advanced, :combobox, _assigns) do
    %{
      id: "team-picker",
      title: "Team Picker",
      description: "Combobox with team options",
      assigns: %{
        id: "docs-combobox-team",
        placeholder: "Select a team",
        value: "Platform",
        option: [
          %{value: "Platform", label: "Platform"},
          %{value: "Design", label: "Design"},
          %{value: "Support", label: "Support"}
        ]
      }
    }
  end

  defp alternate_example(Advanced, :item, _assigns) do
    %{
      id: "disabled-item",
      title: "Disabled Item",
      description: "Unavailable command item state",
      assigns: %{value: "archived", disabled: true, inner_block: slot("Archived project")}
    }
  end

  defp alternate_example(Advanced, :sidebar, _assigns) do
    %{
      id: "docs-layout",
      title: "Docs Layout",
      description: "Sidebar scaffold for documentation surfaces",
      assigns: %{
        rail:
          slot(
            "<nav class=\"space-y-2 text-sm\"><p>Overview</p><p>Components</p><p>Changelog</p></nav>"
          ),
        inset: slot("<div class=\"rounded bg-muted p-4 text-sm\">Main docs content region</div>")
      }
    }
  end

  defp alternate_example(Advanced, :sonner_toaster, _assigns) do
    %{
      id: "top-center",
      title: "Top Center",
      description: "Centered toast mount position",
      assigns: %{position: "top-center"}
    }
  end

  defp alternate_example(_module, _function, assigns) do
    %{
      id: "compact",
      title: "Compact",
      description: "Compact variation inspired by shadcn density patterns",
      assigns: put_compact_class(assigns)
    }
  end

  defp put_compact_class(assigns) when is_map(assigns) do
    Map.put(assigns, :class, merge_classes(assigns[:class], "max-w-sm"))
  end

  defp merge_classes(nil, class), do: class
  defp merge_classes("", class), do: class
  defp merge_classes(existing, class), do: "#{existing} #{class}"

  defp card_profile_assigns do
    badge_html =
      render_component(Feedback, :badge, %{variant: :secondary, inner_block: slot("Active")})

    title_html = render_component(Layout, :card_title, %{inner_block: slot("Philip J. Fry")})

    description_html =
      render_component(Layout, :card_description, %{inner_block: slot("Senior Engineer · Sydney")})

    action_html =
      render_component(Layout, :card_action, %{
        inner_block:
          slot(
            badge_html,
            """
            <.badge variant={:secondary}>Active</.badge>
            """
          )
      })

    header_html =
      render_component(Layout, :card_header, %{
        inner_block:
          slot(
            title_html <> "\n" <> description_html <> "\n" <> action_html,
            """
            <.card_title>Philip J. Fry</.card_title>
            <.card_description>Senior Engineer · Sydney</.card_description>
            <.card_action>
              <.badge variant={:secondary}>Active</.badge>
            </.card_action>
            """
          )
      })

    content_html =
      render_component(Layout, :card_content, %{
        inner_block:
          slot(
            "<p class=\"text-sm text-muted-foreground\">Maintains docs tooling, component APIs, and release workflows.</p>",
            "<p class=\"text-sm text-muted-foreground\">Maintains docs tooling, component APIs, and release workflows.</p>"
          )
      })

    primary_action_html =
      render_component(Actions, :button, %{size: :sm, inner_block: slot("Message")})

    secondary_action_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("View Profile")
      })

    footer_html =
      render_component(Layout, :card_footer, %{
        inner_block:
          slot(
            primary_action_html <> "\n" <> secondary_action_html,
            """
            <.button size={:sm}>Message</.button>
            <.button variant={:outline} size={:sm}>View Profile</.button>
            """
          )
      })

    %{
      inner_block:
        slot(
          header_html <> "\n" <> content_html <> "\n" <> footer_html,
          """
          <.card_header>
            <.card_title>Philip J. Fry</.card_title>
            <.card_description>Senior Engineer · Sydney</.card_description>
            <.card_action>
              <.badge variant={:secondary}>Active</.badge>
            </.card_action>
          </.card_header>
          <.card_content>
            <p class="text-sm text-muted-foreground">
              Maintains docs tooling, component APIs, and release workflows.
            </p>
          </.card_content>
          <.card_footer>
            <.button size={:sm}>Message</.button>
            <.button variant={:outline} size={:sm}>View Profile</.button>
          </.card_footer>
          """
        )
    }
  end

  defp card_pricing_assigns do
    title_html = render_component(Layout, :card_title, %{inner_block: slot("Pro Plan")})

    description_html =
      render_component(Layout, :card_description, %{
        inner_block: slot("Best for production teams shipping weekly.")
      })

    header_html =
      render_component(Layout, :card_header, %{
        inner_block:
          slot(
            title_html <> "\n" <> description_html,
            """
            <.card_title>Pro Plan</.card_title>
            <.card_description>Best for production teams shipping weekly.</.card_description>
            """
          )
      })

    content_html =
      render_component(Layout, :card_content, %{
        inner_block:
          slot(
            """
            <p class=\"text-2xl font-semibold\">$49<span class=\"text-sm font-normal text-muted-foreground\">/month</span></p>
            <ul class=\"mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground\">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
            """,
            """
            <p class="text-2xl font-semibold">$49<span class="text-sm font-normal text-muted-foreground">/month</span></p>
            <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
            """
          )
      })

    cta_html =
      render_component(Actions, :button, %{
        class: "w-full",
        inner_block: slot("Start 14-day trial")
      })

    footer_html =
      render_component(Layout, :card_footer, %{
        inner_block:
          slot(
            cta_html,
            """
            <.button class="w-full">Start 14-day trial</.button>
            """
          )
      })

    %{
      inner_block:
        slot(
          header_html <> "\n" <> content_html <> "\n" <> footer_html,
          """
          <.card_header>
            <.card_title>Pro Plan</.card_title>
            <.card_description>Best for production teams shipping weekly.</.card_description>
          </.card_header>
          <.card_content>
            <p class="text-2xl font-semibold">$49<span class="text-sm font-normal text-muted-foreground">/month</span></p>
            <ul class="mt-2 list-disc space-y-1 pl-4 text-sm text-muted-foreground">
              <li>Unlimited projects</li>
              <li>Priority support</li>
              <li>Team analytics</li>
            </ul>
          </.card_content>
          <.card_footer>
            <.button class="w-full">Start 14-day trial</.button>
          </.card_footer>
          """
        )
    }
  end

  defp field_validation_assigns do
    label_html =
      render_component(Forms, :label, %{
        for: "docs-password",
        inner_block: slot("Password")
      })

    input_html =
      render_component(Forms, :input, %{
        id: "docs-password",
        type: "password",
        value: "short"
      })

    %{
      label:
        slot(
          label_html,
          """
          <.label for="docs-password">Password</.label>
          """
        ),
      description: slot("Use at least 12 characters."),
      error: slot("Password must include at least one symbol."),
      inner_block:
        slot(
          input_html,
          """
          <.input id="docs-password" type="password" value="short" />
          """
        )
    }
  end

  defp destructive_alert_assigns do
    icon_html = render_component(Icons, :icon, %{name: "triangle-alert", class: "size-4"})

    title_html = render_component(Feedback, :alert_title, %{inner_block: slot("Deploy blocked")})

    description_html =
      render_component(Feedback, :alert_description, %{
        inner_block: slot("Production checks failed. Resolve blockers before redeploying.")
      })

    %{
      variant: :destructive,
      inner_block:
        slot(
          """
          #{icon_html}
          #{title_html}
          #{description_html}
          """,
          """
          <.icon name="triangle-alert" class="size-4" />
          <.alert_title>Deploy blocked</.alert_title>
          <.alert_description>
            Production checks failed. Resolve blockers before redeploying.
          </.alert_description>
          """
        )
    }
  end

  defp release_notes_accordion_assigns do
    %{
      item: [
        %{
          title: "v0.4.0 · New components",
          open: true,
          inner_block: fn _, _ -> "Added pagination, tabs, and command palette docs pages." end
        },
        %{
          title: "v0.3.2 · Docs quality",
          inner_block: fn _, _ -> "Added generated attr/slot tables and HEEx copy snippets." end
        },
        %{
          title: "v0.3.0 · Static site",
          inner_block: fn _, _ -> "Introduced static docs export and theme controls." end
        }
      ]
    }
  end

  defp line_tabs_assigns do
    %{
      value: "profile",
      variant: :line,
      trigger: [
        %{value: "profile", inner_block: fn _, _ -> "Profile" end},
        %{value: "security", inner_block: fn _, _ -> "Security" end},
        %{value: "billing", inner_block: fn _, _ -> "Billing" end}
      ],
      content: [
        %{value: "profile", inner_block: fn _, _ -> "Update your profile preferences." end},
        %{value: "security", inner_block: fn _, _ -> "Manage MFA, passkeys, and sessions." end},
        %{value: "billing", inner_block: fn _, _ -> "Control plan and payment settings." end}
      ]
    }
  end

  defp destructive_dialog_assigns do
    trigger_html =
      render_component(Actions, :button, %{
        variant: :outline,
        inner_block: slot("Delete project")
      })

    cancel_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Cancel")
      })

    delete_html =
      render_component(Actions, :button, %{
        variant: :destructive,
        size: :sm,
        inner_block: slot("Delete")
      })

    %{
      id: "docs-dialog-destructive",
      open: false,
      trigger:
        slot(
          trigger_html,
          """
          <.button variant={:outline}>Delete project</.button>
          """
        ),
      title: slot("Delete project?"),
      description: slot("This action permanently removes deployments and analytics."),
      inner_block:
        slot(
          "<p class=\"text-sm text-muted-foreground\">Type the project name to confirm deletion.</p>",
          "<p class=\"text-sm text-muted-foreground\">Type the project name to confirm deletion.</p>"
        ),
      footer:
        slot(
          cancel_html <> "\n" <> delete_html,
          """
          <.button variant={:outline} size={:sm}>Cancel</.button>
          <.button variant={:destructive} size={:sm}>Delete</.button>
          """
        )
    }
  end

  defp project_switcher_command_assigns do
    docs_item_html =
      render_component(Advanced, :item, %{value: "docs", inner_block: slot("Docs site")})

    demo_item_html =
      render_component(Advanced, :item, %{value: "demo", inner_block: slot("Demo app")})

    platform_item_html =
      render_component(Advanced, :item, %{value: "platform", inner_block: slot("Platform team")})

    %{
      placeholder: "Jump to project...",
      group: [
        %{
          heading: "Projects",
          inner_block: fn _, _ -> HTML.raw(docs_item_html <> "\n" <> demo_item_html) end,
          template: """
          <.item value="docs">Docs site</.item>
          <.item value="demo">Demo app</.item>
          """
        },
        %{
          heading: "Teams",
          inner_block: fn _, _ -> HTML.raw(platform_item_html) end,
          template: """
          <.item value="platform">Platform team</.item>
          """
        }
      ]
    }
  end

  defp command_palette_assigns do
    profile_item_html =
      render_component(Advanced, :item, %{value: "profile", inner_block: slot("Profile")})

    billing_item_html =
      render_component(Advanced, :item, %{value: "billing", inner_block: slot("Billing")})

    settings_item_html =
      render_component(Advanced, :item, %{value: "settings", inner_block: slot("Settings")})

    %{
      placeholder: "Search commands...",
      group: [
        %{
          heading: "General",
          inner_block: fn _, _ -> HTML.raw(profile_item_html <> "\n" <> billing_item_html) end,
          template: """
          <.item value="profile">Profile</.item>
          <.item value="billing">Billing</.item>
          """
        },
        %{
          heading: "Workspace",
          inner_block: fn _, _ -> HTML.raw(settings_item_html) end,
          template: """
          <.item value="settings">Settings</.item>
          """
        }
      ]
    }
  end

  defp sample_assigns(Actions, :button) do
    %{inner_block: slot("Button")}
  end

  defp sample_assigns(Actions, :button_group) do
    left_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Left")
      })

    right_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Right")
      })

    %{
      inner_block:
        slot(
          left_button_html <> "\n" <> right_button_html,
          """
          <.button variant={:outline} size={:sm}>Left</.button>
          <.button variant={:outline} size={:sm}>Right</.button>
          """
        )
    }
  end

  defp sample_assigns(Actions, :toggle) do
    %{pressed: true, inner_block: slot("Bold")}
  end

  defp sample_assigns(Actions, :toggle_group) do
    toggle_a_html =
      render_component(Actions, :toggle, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("A")
      })

    toggle_b_html =
      render_component(Actions, :toggle, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("B")
      })

    %{
      inner_block:
        slot(
          toggle_a_html <> "\n" <> toggle_b_html,
          """
          <.toggle variant={:outline} size={:sm}>A</.toggle>
          <.toggle variant={:outline} size={:sm}>B</.toggle>
          """
        )
    }
  end

  defp sample_assigns(Forms, :checkbox),
    do: %{id: "docs-checkbox", checked: true, inner_block: slot("Accept terms")}

  defp sample_assigns(Forms, :field) do
    label_html =
      render_component(Forms, :label, %{for: "docs-field-input", inner_block: slot("Username")})

    input_html = render_component(Forms, :input, %{id: "docs-field-input", value: "levi"})

    %{
      label:
        slot(
          label_html,
          """
          <.label for="docs-field-input">Username</.label>
          """
        ),
      description: slot("This is your public identifier."),
      error: slot(""),
      inner_block:
        slot(
          input_html,
          ~S(<.input id="docs-field-input" value="levi" />)
        )
    }
  end

  defp sample_assigns(Forms, :input),
    do: %{id: "docs-input", placeholder: "name@example.com", type: "email"}

  defp sample_assigns(Forms, :input_group) do
    search_input_html = render_component(Forms, :input, %{value: "search"})

    go_button_html =
      render_component(Actions, :button, %{variant: :outline, inner_block: slot("Go")})

    %{
      inner_block:
        slot(
          search_input_html <> "\n" <> go_button_html,
          """
          <.input value="search" />
          <.button variant={:outline}>Go</.button>
          """
        )
    }
  end

  defp sample_assigns(Forms, :input_otp),
    do: %{name: "code[]", values: ["1", "2", "", "", "", ""]}

  defp sample_assigns(Forms, :label), do: %{for: "docs-input", inner_block: slot("Email")}

  defp sample_assigns(Forms, :radio_group) do
    %{
      name: "team-size",
      value: "small",
      option: [
        %{value: "solo", label: "Solo"},
        %{value: "small", label: "Small"}
      ]
    }
  end

  defp sample_assigns(Forms, :select) do
    %{
      name: "plan",
      value: "pro",
      option: [
        %{value: "free", label: "Free"},
        %{value: "pro", label: "Pro"}
      ]
    }
  end

  defp sample_assigns(Forms, :slider), do: %{id: "docs-slider", value: 65}

  defp sample_assigns(Forms, :switch),
    do: %{id: "docs-switch", checked: true, inner_block: slot("Enabled")}

  defp sample_assigns(Forms, :textarea), do: %{id: "docs-textarea", value: "Textarea value"}

  defp sample_assigns(Layout, :aspect_ratio) do
    %{
      ratio: "16 / 9",
      inner_block:
        slot(
          "<div class=\"flex h-full w-full items-center justify-center bg-muted text-xs text-muted-foreground\">16:9</div>"
        )
    }
  end

  defp sample_assigns(Layout, :card) do
    card_profile_assigns()
  end

  defp sample_assigns(Layout, :card_action), do: %{inner_block: slot("Action")}
  defp sample_assigns(Layout, :card_content), do: %{inner_block: slot("Card content")}
  defp sample_assigns(Layout, :card_description), do: %{inner_block: slot("Card description")}
  defp sample_assigns(Layout, :card_footer), do: %{inner_block: slot("Card footer")}
  defp sample_assigns(Layout, :card_header), do: %{inner_block: slot("Card header")}
  defp sample_assigns(Layout, :card_title), do: %{inner_block: slot("Card title")}
  defp sample_assigns(Layout, :kbd), do: %{inner_block: slot("⌘K")}

  defp sample_assigns(Layout, :kbd_group),
    do: %{inner_block: slot("<span>⌘</span><span>K</span>")}

  defp sample_assigns(Layout, :resizable) do
    %{
      direction: :horizontal,
      panel: [
        %{
          size: 35,
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>")
          end,
          template: "<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>"
        },
        %{
          size: 65,
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>")
          end,
          template: "<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>"
        }
      ]
    }
  end

  defp sample_assigns(Layout, :scroll_area),
    do: %{
      class: "h-20 rounded-md border",
      inner_block:
        slot(
          Enum.map_join(1..8, "", fn index ->
            ~s(<div class="py-1 text-sm">Scrollable content #{index}</div>)
          end),
          Enum.map_join(1..8, "\n", fn index ->
            ~s(<div class="py-1 text-sm">Scrollable content #{index}</div>)
          end)
        )
    }

  defp sample_assigns(Layout, :separator), do: %{orientation: :horizontal}
  defp sample_assigns(Layout, :skeleton), do: %{class: "h-4 w-40"}
  defp sample_assigns(Icons, :icon), do: %{name: "circle-alert", class: "size-4"}

  defp sample_assigns(Feedback, :alert) do
    icon_html = render_component(Icons, :icon, %{name: "circle-alert", class: "size-4"})

    %{
      inner_block:
        slot(
          """
          #{icon_html}
          <div data-slot=\"alert-title\" class=\"font-medium\">Notice</div>
          <div data-slot=\"alert-description\" class=\"text-sm\">Build completed.</div>
          """,
          """
          <.icon name="circle-alert" class="size-4" />
          <.alert_title>Notice</.alert_title>
          <.alert_description>Build completed.</.alert_description>
          """
        )
    }
  end

  defp sample_assigns(Feedback, :alert_description), do: %{inner_block: slot("Description text")}
  defp sample_assigns(Feedback, :alert_title), do: %{inner_block: slot("Alert title")}
  defp sample_assigns(Feedback, :badge), do: %{variant: :secondary, inner_block: slot("Beta")}

  defp sample_assigns(Feedback, :empty_state) do
    reset_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Reset")
      })

    %{
      title: slot("No results"),
      description: slot("Try a different filter."),
      action:
        slot(
          reset_html,
          "<.button variant={:outline} size={:sm}>Reset</.button>"
        ),
      icon: slot("<span class=\"text-xl\">◌</span>")
    }
  end

  defp sample_assigns(Feedback, :progress), do: %{value: 72}
  defp sample_assigns(Feedback, :spinner), do: %{}

  defp sample_assigns(Feedback, :toast) do
    toast_item_html =
      render_component(Feedback, :toast_item, %{
        inner_block: slot("Project settings saved.")
      })

    %{
      class: "static z-0 w-full max-w-none p-0",
      inner_block:
        slot(
          toast_item_html,
          """
          <.toast_item>Project settings saved.</.toast_item>
          """
        )
    }
  end

  defp sample_assigns(Feedback, :toast_item),
    do: %{inner_block: slot("Project settings saved.")}

  defp sample_assigns(DataDisplay, :accordion) do
    %{
      item: [
        %{title: "What is this?", open: true, inner_block: fn _, _ -> "A static preview." end},
        %{
          title: "Is it interactive?",
          inner_block: fn _, _ -> "Some components are progressively enhanced." end
        }
      ]
    }
  end

  defp sample_assigns(DataDisplay, :avatar) do
    %{src: avatar_sample_data_uri(:levi), alt: "Philip J. Fry"}
  end

  defp sample_assigns(DataDisplay, :avatar_group) do
    preview_html =
      [
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:levi),
          alt: "Philip J. Fry"
        }),
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:ari),
          alt: "Ari Miles"
        }),
        render_component(DataDisplay, :avatar, %{
          src: avatar_sample_data_uri(:noor),
          alt: "Noor Hale"
        }),
        render_component(DataDisplay, :avatar_group_count, %{inner_block: slot("+2")})
      ]
      |> Enum.join("\n")

    %{
      inner_block:
        slot(
          preview_html,
          """
          <.avatar src="#{avatar_sample_data_uri(:levi)}" alt="Philip J. Fry" />
          <.avatar src="#{avatar_sample_data_uri(:ari)}" alt="Ari Miles" />
          <.avatar src="#{avatar_sample_data_uri(:noor)}" alt="Noor Hale" />
          <.avatar_group_count>+2</.avatar_group_count>
          """
        )
    }
  end

  defp sample_assigns(DataDisplay, :avatar_group_count), do: %{inner_block: slot("+3")}

  defp sample_assigns(DataDisplay, :code_block),
    do: %{inner_block: slot("mix cinder_ui.docs.build")}

  defp sample_assigns(DataDisplay, :collapsible) do
    %{open: true, trigger: slot("Toggle details"), inner_block: slot("Expanded content")}
  end

  defp sample_assigns(DataDisplay, :table) do
    %{
      inner_block:
        slot(
          """
          <caption data-slot=\"table-caption\">Deployment status</caption>
          <thead data-slot=\"table-header\">
            <tr data-slot=\"table-row\">
              <th data-slot=\"table-head\">Service</th>
              <th data-slot=\"table-head\">Owner</th>
              <th data-slot=\"table-head\">Status</th>
            </tr>
          </thead>
          <tbody data-slot=\"table-body\">
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\">API</td>
              <td data-slot=\"table-cell\">Platform</td>
              <td data-slot=\"table-cell\">Healthy</td>
            </tr>
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\">Worker</td>
              <td data-slot=\"table-cell\">Backend</td>
              <td data-slot=\"table-cell\">Degraded</td>
            </tr>
          </tbody>
          <tfoot data-slot=\"table-footer\">
            <tr data-slot=\"table-row\">
              <td data-slot=\"table-cell\" colspan=\"3\">Last updated 2 minutes ago</td>
            </tr>
          </tfoot>
          """,
          """
          <.table_caption>Deployment status</.table_caption>
          <.table_header>
            <.table_row>
              <.table_head>Service</.table_head>
              <.table_head>Owner</.table_head>
              <.table_head>Status</.table_head>
            </.table_row>
          </.table_header>
          <.table_body>
            <.table_row>
              <.table_cell>API</.table_cell>
              <.table_cell>Platform</.table_cell>
              <.table_cell>Healthy</.table_cell>
            </.table_row>
            <.table_row>
              <.table_cell>Worker</.table_cell>
              <.table_cell>Backend</.table_cell>
              <.table_cell>Degraded</.table_cell>
            </.table_row>
          </.table_body>
          <.table_footer>
            <.table_row>
              <.table_cell>Last updated 2 minutes ago</.table_cell>
            </.table_row>
          </.table_footer>
          """
        )
    }
  end

  defp sample_assigns(DataDisplay, :table_body),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><td data-slot="table-cell">Cell</td></tr>),
          """
          <.table_row>
            <.table_cell>Cell</.table_cell>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_caption), do: %{inner_block: slot("Table caption")}
  defp sample_assigns(DataDisplay, :table_cell), do: %{inner_block: slot("Cell")}

  defp sample_assigns(DataDisplay, :table_footer),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><td data-slot="table-cell">Footer</td></tr>),
          """
          <.table_row>
            <.table_cell>Footer</.table_cell>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_head), do: %{inner_block: slot("Head")}

  defp sample_assigns(DataDisplay, :table_header),
    do: %{
      inner_block:
        slot(
          ~S(<tr data-slot="table-row"><th data-slot="table-head">Head</th></tr>),
          """
          <.table_row>
            <.table_head>Head</.table_head>
          </.table_row>
          """
        )
    }

  defp sample_assigns(DataDisplay, :table_row),
    do: %{
      inner_block: slot("<td data-slot=\"table-cell\">Row</td>", "<.table_cell>Row</.table_cell>")
    }

  defp sample_assigns(Navigation, :breadcrumb) do
    %{
      inner_block:
        slot(
          """
          <ol data-slot=\"breadcrumb-list\" class=\"flex items-center gap-2\">
            <li data-slot=\"breadcrumb-item\"><a data-slot=\"breadcrumb-link\" href=\"#\">Home</a></li>
            <li data-slot=\"breadcrumb-separator\">/</li>
            <li data-slot=\"breadcrumb-item\"><span data-slot=\"breadcrumb-page\">Docs</span></li>
          </ol>
          """,
          """
          <.breadcrumb_list>
            <.breadcrumb_item>
              <.breadcrumb_link href="#">Home</.breadcrumb_link>
            </.breadcrumb_item>
            <.breadcrumb_separator>/</.breadcrumb_separator>
            <.breadcrumb_item>
              <.breadcrumb_page>Docs</.breadcrumb_page>
            </.breadcrumb_item>
          </.breadcrumb_list>
          """
        )
    }
  end

  defp sample_assigns(Navigation, :breadcrumb_ellipsis), do: %{}
  defp sample_assigns(Navigation, :breadcrumb_item), do: %{inner_block: slot("Item")}
  defp sample_assigns(Navigation, :breadcrumb_link), do: %{href: "#", inner_block: slot("Home")}

  defp sample_assigns(Navigation, :breadcrumb_list),
    do: %{
      inner_block:
        slot(
          "<li data-slot=\"breadcrumb-item\">Item</li>",
          "<.breadcrumb_item>Item</.breadcrumb_item>"
        )
    }

  defp sample_assigns(Navigation, :breadcrumb_page), do: %{inner_block: slot("Current")}
  defp sample_assigns(Navigation, :breadcrumb_separator), do: %{}

  defp sample_assigns(Navigation, :navigation_menu) do
    %{
      item: [
        %{href: "#", active: true, inner_block: fn _, _ -> "Overview" end},
        %{href: "#", inner_block: fn _, _ -> "Settings" end}
      ]
    }
  end

  defp sample_assigns(Navigation, :menu) do
    %{
      item: [
        %{href: "#", active: true, inner_block: fn _, _ -> "Overview" end},
        %{href: "#", inner_block: fn _, _ -> "Team" end},
        %{href: "#", disabled: true, inner_block: fn _, _ -> "Billing" end}
      ]
    }
  end

  defp sample_assigns(Navigation, :pagination) do
    %{
      inner_block:
        slot(
          """
          <ul data-slot=\"pagination-content\" class=\"flex items-center gap-1\">
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-previous\" href=\"#\">Previous</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">1</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">2</a></li>
            <li data-slot=\"pagination-item\"><span data-slot=\"pagination-ellipsis\">…</span></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">8</a></li>
            <li data-slot=\"pagination-item\"><a data-slot=\"pagination-next\" href=\"#\">Next</a></li>
          </ul>
          """,
          """
          <.pagination_content>
            <.pagination_item>
              <.pagination_previous href="#" />
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm}>1</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm} active={true}>2</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_ellipsis />
            </.pagination_item>
            <.pagination_item>
              <.pagination_link href="#" size={:sm}>8</.pagination_link>
            </.pagination_item>
            <.pagination_item>
              <.pagination_next href="#" />
            </.pagination_item>
          </.pagination_content>
          """
        )
    }
  end

  defp sample_assigns(Navigation, :pagination_content),
    do: %{
      inner_block:
        slot(
          "<li data-slot=\"pagination-item\">Page</li>",
          "<.pagination_item>Page</.pagination_item>"
        )
    }

  defp sample_assigns(Navigation, :pagination_ellipsis), do: %{}
  defp sample_assigns(Navigation, :pagination_item), do: %{inner_block: slot("Item")}

  defp sample_assigns(Navigation, :pagination_link),
    do: %{href: "#", active: true, inner_block: slot("1")}

  defp sample_assigns(Navigation, :pagination_next), do: %{href: "#"}
  defp sample_assigns(Navigation, :pagination_previous), do: %{href: "#"}

  defp sample_assigns(Navigation, :tabs) do
    %{
      value: "overview",
      trigger: [
        %{value: "overview", inner_block: fn _, _ -> "Overview" end},
        %{value: "settings", inner_block: fn _, _ -> "Settings" end}
      ],
      content: [
        %{value: "overview", inner_block: fn _, _ -> "Overview content" end},
        %{value: "settings", inner_block: fn _, _ -> "Settings content" end}
      ]
    }
  end

  defp sample_assigns(Overlay, :alert_dialog) do
    cancel_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Cancel")
      })

    %{
      id: "docs-alert-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Delete project?"),
      description: slot("This action is irreversible."),
      inner_block: slot("Dialog body"),
      footer:
        slot(
          cancel_button_html,
          "<.button variant={:outline} size={:sm}>Cancel</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :dialog) do
    done_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Done")
      })

    %{
      id: "docs-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Dialog title"),
      description: slot("Dialog description"),
      inner_block: slot("Dialog body"),
      footer:
        slot(
          done_button_html,
          "<.button variant={:outline} size={:sm}>Done</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :drawer) do
    save_button_html =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        inner_block: slot("Save")
      })

    %{
      id: "docs-drawer",
      open: false,
      side: :right,
      trigger: slot("Open"),
      title: slot("Drawer"),
      description: slot("Drawer description"),
      inner_block: slot("Drawer body"),
      footer:
        slot(
          save_button_html,
          "<.button variant={:outline} size={:sm}>Save</.button>"
        )
    }
  end

  defp sample_assigns(Overlay, :dropdown_menu) do
    %{
      id: "docs-dropdown",
      trigger: slot("Actions"),
      item: [
        %{href: "#", inner_block: fn _, _ -> "Settings" end},
        %{href: "#", inner_block: fn _, _ -> "Billing" end}
      ]
    }
  end

  defp sample_assigns(Overlay, :hover_card) do
    %{trigger: slot("Hover card"), content: slot("Hover content")}
  end

  defp sample_assigns(Overlay, :menubar) do
    new_button_html =
      render_component(Actions, :button, %{
        variant: :ghost,
        size: :sm,
        class: "w-full justify-start",
        inner_block: slot("New")
      })

    %{
      menu: [
        %{
          label: "File",
          inner_block: fn _, _ -> HTML.raw(new_button_html) end,
          template:
            "<.button variant={:ghost} size={:sm} class=\"w-full justify-start\">New</.button>"
        }
      ]
    }
  end

  defp sample_assigns(Overlay, :popover) do
    %{id: "docs-popover", trigger: slot("Popover"), content: slot("Popover content")}
  end

  defp sample_assigns(Overlay, :sheet) do
    sample_assigns(Overlay, :drawer)
    |> Map.put(:id, "docs-sheet")
  end

  defp sample_assigns(Overlay, :tooltip),
    do: %{
      text: "Tooltip text",
      # The trigger can be any interactive component.
      inner_block:
        slot(
          render_component(Actions, :button, %{
            variant: :outline,
            size: :sm,
            inner_block: slot("Hover me")
          }),
          """
          <.button variant={:outline} size={:sm}>Hover me</.button>
          """
        )
    }

  defp sample_assigns(Advanced, :calendar),
    do: %{
      inner_block: slot("<div class=\"text-sm text-muted-foreground\">Calendar container</div>")
    }

  defp sample_assigns(Advanced, :carousel) do
    %{
      id: "docs-carousel",
      item: [
        %{
          inner_block: fn _, _ -> HTML.raw("<div class=\"h-24 rounded-md bg-muted\"></div>") end,
          template: "<div class=\"h-24 rounded-md bg-muted\"></div>"
        },
        %{
          inner_block: fn _, _ ->
            HTML.raw("<div class=\"h-24 rounded-md bg-muted/60\"></div>")
          end,
          template: "<div class=\"h-24 rounded-md bg-muted/60\"></div>"
        }
      ]
    }
  end

  defp sample_assigns(Advanced, :chart) do
    %{
      title: slot("Requests"),
      description: slot("Last 24h"),
      inner_block: slot("<div class=\"h-24 rounded bg-muted\"></div>")
    }
  end

  defp sample_assigns(Advanced, :combobox) do
    %{
      id: "docs-combobox",
      value: "Pro",
      option: [%{value: "Free", label: "Free"}, %{value: "Pro", label: "Pro"}]
    }
  end

  defp sample_assigns(Advanced, :command) do
    command_palette_assigns()
  end

  defp sample_assigns(Advanced, :item), do: %{value: "profile", inner_block: slot("Profile")}

  defp sample_assigns(Advanced, :sidebar) do
    %{
      rail: slot("<nav class=\"space-y-2 text-sm\"><p>Dashboard</p><p>Settings</p></nav>"),
      inset: slot("<div class=\"rounded bg-muted p-4 text-sm\">Main content</div>")
    }
  end

  defp sample_assigns(Advanced, :sonner_toaster), do: %{position: "bottom-right"}

  defp sample_assigns(Components, _function), do: %{}

  defp avatar_sample_data_uri(:levi), do: @avatar_data_levi
  defp avatar_sample_data_uri(:ari), do: @avatar_data_ari
  defp avatar_sample_data_uri(:noor), do: @avatar_data_noor

  defp slot(content, template_content \\ nil) do
    [
      %{
        inner_block: fn _, _ -> HTML.raw(content) end,
        template: template_content
      }
    ]
  end
end
