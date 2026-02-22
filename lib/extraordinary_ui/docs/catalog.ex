defmodule ExtraordinaryUI.Docs.Catalog do
  @moduledoc """
  Static documentation catalog used by `mix extraordinary_ui.docs.build`.

  The catalog renders every public `*/1` component function and returns data
  required to build the static docs site.
  """

  alias ExtraordinaryUI.Components
  alias ExtraordinaryUI.Components.Actions
  alias ExtraordinaryUI.Components.Advanced
  alias ExtraordinaryUI.Components.DataDisplay
  alias ExtraordinaryUI.Components.Feedback
  alias ExtraordinaryUI.Components.Forms
  alias ExtraordinaryUI.Components.Layout
  alias ExtraordinaryUI.Components.Navigation
  alias ExtraordinaryUI.Components.Overlay

  @sections [
    %{id: "actions", title: "Actions", module: Actions},
    %{id: "forms", title: "Forms", module: Forms},
    %{id: "layout", title: "Layout", module: Layout},
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
    assigns = sample_assigns(module, function)

    %{
      id: "#{module_slug(module)}-#{function}",
      title: Atom.to_string(function),
      function: function,
      module: module,
      module_name: module |> Module.split() |> List.last(),
      docs: first_paragraph(module, function),
      preview_html: render_component(module, function, assigns)
    }
  end

  defp module_slug(module) do
    module
    |> Module.split()
    |> List.last()
    |> Macro.underscore()
    |> String.replace("_", "-")
  end

  defp first_paragraph(module, function) do
    with {:docs_v1, _, _, _, _, _, docs} <- Code.fetch_docs(module),
         {{:function, ^function, 1}, _, _, %{"en" => doc}, _} <-
           Enum.find(docs, fn
             {{:function, name, 1}, _, _, %{"en" => _}, _} -> name == function
             _ -> false
           end) do
      doc
      |> String.split("\n\n")
      |> List.first()
      |> String.trim()
    else
      _ -> "No documentation available."
    end
  end

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  rescue
    exception ->
      escaped =
        exception
        |> Exception.format(:error)
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()

      "<pre class=\"text-destructive text-xs\">#{escaped}</pre>"
  end

  defp sample_assigns(Actions, :button) do
    %{inner_block: slot("Button")}
  end

  defp sample_assigns(Actions, :button_group) do
    %{
      inner_block:
        slot("""
        <button class=\"inline-flex h-8 items-center rounded-md border px-3 text-xs\">Left</button>
        <button class=\"inline-flex h-8 items-center rounded-md border px-3 text-xs\">Right</button>
        """)
    }
  end

  defp sample_assigns(Actions, :toggle) do
    %{pressed: true, inner_block: slot("Bold")}
  end

  defp sample_assigns(Actions, :toggle_group) do
    %{
      inner_block:
        slot("""
        <button class=\"inline-flex h-8 items-center rounded-md border px-2 text-xs\">A</button>
        <button class=\"inline-flex h-8 items-center rounded-md border px-2 text-xs\">B</button>
        """)
    }
  end

  defp sample_assigns(Forms, :checkbox),
    do: %{id: "docs-checkbox", checked: true, inner_block: slot("Accept terms")}

  defp sample_assigns(Forms, :field) do
    %{
      label: slot("Username"),
      description: slot("This is your public identifier."),
      error: slot(""),
      inner_block: slot("<input class=\"h-9 w-full rounded-md border px-3\" value=\"levi\" />")
    }
  end

  defp sample_assigns(Forms, :input),
    do: %{id: "docs-input", placeholder: "name@example.com", type: "email"}

  defp sample_assigns(Forms, :input_group) do
    %{
      inner_block:
        slot("""
        <input class=\"h-9 flex-1 px-3\" value=\"search\" />
        <button class=\"h-9 px-3 text-xs\">Go</button>
        """)
    }
  end

  defp sample_assigns(Forms, :input_otp),
    do: %{name: "code[]", values: ["1", "2", "", "", "", ""]}

  defp sample_assigns(Forms, :label), do: %{for: "docs-input", inner_block: slot("Email")}

  defp sample_assigns(Forms, :native_select), do: sample_assigns(Forms, :select)

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
    %{
      inner_block:
        slot("""
        <div class=\"px-6 text-sm\">Card body</div>
        """)
    }
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
            "<div class=\"rounded-md bg-muted p-2 text-xs\">Panel A</div>"
          end
        },
        %{
          size: 65,
          inner_block: fn _, _ ->
            "<div class=\"rounded-md bg-muted/60 p-2 text-xs\">Panel B</div>"
          end
        }
      ]
    }
  end

  defp sample_assigns(Layout, :scroll_area),
    do: %{
      class: "h-20 rounded-md border",
      inner_block: slot(String.duplicate("Scrollable content ", 12))
    }

  defp sample_assigns(Layout, :separator), do: %{orientation: :horizontal}
  defp sample_assigns(Layout, :skeleton), do: %{class: "h-4 w-40"}

  defp sample_assigns(Feedback, :alert) do
    %{
      inner_block:
        slot("""
        <svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\" class=\"size-4\"><path d=\"M12 2a10 10 0 100 20 10 10 0 000-20z\" /></svg>
        <div data-slot=\"alert-title\" class=\"font-medium\">Notice</div>
        <div data-slot=\"alert-description\" class=\"text-sm\">Build completed.</div>
        """)
    }
  end

  defp sample_assigns(Feedback, :alert_description), do: %{inner_block: slot("Description text")}
  defp sample_assigns(Feedback, :alert_title), do: %{inner_block: slot("Alert title")}
  defp sample_assigns(Feedback, :badge), do: %{variant: :secondary, inner_block: slot("Beta")}

  defp sample_assigns(Feedback, :empty_state) do
    %{
      title: slot("No results"),
      description: slot("Try a different filter."),
      action:
        slot("<button class=\"inline-flex h-8 rounded-md border px-3 text-xs\">Reset</button>"),
      icon: slot("<span class=\"text-xl\">◌</span>")
    }
  end

  defp sample_assigns(Feedback, :progress), do: %{value: 72}
  defp sample_assigns(Feedback, :spinner), do: %{}

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

  defp sample_assigns(DataDisplay, :avatar), do: %{alt: "Levi Noah"}

  defp sample_assigns(DataDisplay, :avatar_group) do
    %{
      inner_block:
        slot("""
        <div data-slot=\"avatar\" class=\"size-8 rounded-full bg-muted\"></div>
        <div data-slot=\"avatar\" class=\"size-8 rounded-full bg-muted/60\"></div>
        """)
    }
  end

  defp sample_assigns(DataDisplay, :avatar_group_count), do: %{inner_block: slot("+3")}

  defp sample_assigns(DataDisplay, :code_block),
    do: %{inner_block: slot("mix extraordinary_ui.docs.build")}

  defp sample_assigns(DataDisplay, :collapsible) do
    %{open: true, trigger: slot("Toggle details"), inner_block: slot("Expanded content")}
  end

  defp sample_assigns(DataDisplay, :table) do
    %{
      inner_block:
        slot("""
        <thead data-slot=\"table-header\"><tr data-slot=\"table-row\"><th data-slot=\"table-head\">Name</th><th data-slot=\"table-head\">Status</th></tr></thead>
        <tbody data-slot=\"table-body\"><tr data-slot=\"table-row\"><td data-slot=\"table-cell\">Web</td><td data-slot=\"table-cell\">Healthy</td></tr></tbody>
        """)
    }
  end

  defp sample_assigns(DataDisplay, :table_body),
    do: %{
      inner_block: slot("<tr data-slot=\"table-row\"><td data-slot=\"table-cell\">Cell</td></tr>")
    }

  defp sample_assigns(DataDisplay, :table_caption), do: %{inner_block: slot("Table caption")}
  defp sample_assigns(DataDisplay, :table_cell), do: %{inner_block: slot("Cell")}

  defp sample_assigns(DataDisplay, :table_footer),
    do: %{
      inner_block:
        slot("<tr data-slot=\"table-row\"><td data-slot=\"table-cell\">Footer</td></tr>")
    }

  defp sample_assigns(DataDisplay, :table_head), do: %{inner_block: slot("Head")}

  defp sample_assigns(DataDisplay, :table_header),
    do: %{
      inner_block: slot("<tr data-slot=\"table-row\"><th data-slot=\"table-head\">Head</th></tr>")
    }

  defp sample_assigns(DataDisplay, :table_row),
    do: %{inner_block: slot("<td data-slot=\"table-cell\">Row</td>")}

  defp sample_assigns(Navigation, :breadcrumb) do
    %{
      inner_block:
        slot("""
        <ol data-slot=\"breadcrumb-list\" class=\"flex items-center gap-2\">
          <li data-slot=\"breadcrumb-item\"><a data-slot=\"breadcrumb-link\" href=\"#\">Home</a></li>
          <li data-slot=\"breadcrumb-separator\">/</li>
          <li data-slot=\"breadcrumb-item\"><span data-slot=\"breadcrumb-page\">Docs</span></li>
        </ol>
        """)
    }
  end

  defp sample_assigns(Navigation, :breadcrumb_ellipsis), do: %{}
  defp sample_assigns(Navigation, :breadcrumb_item), do: %{inner_block: slot("Item")}
  defp sample_assigns(Navigation, :breadcrumb_link), do: %{href: "#", inner_block: slot("Home")}

  defp sample_assigns(Navigation, :breadcrumb_list),
    do: %{inner_block: slot("<li data-slot=\"breadcrumb-item\">Item</li>")}

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

  defp sample_assigns(Navigation, :pagination) do
    %{
      inner_block:
        slot("""
        <ul data-slot=\"pagination-content\" class=\"flex items-center gap-1\">
          <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">1</a></li>
          <li data-slot=\"pagination-item\"><a data-slot=\"pagination-link\" href=\"#\">2</a></li>
        </ul>
        """)
    }
  end

  defp sample_assigns(Navigation, :pagination_content),
    do: %{inner_block: slot("<li data-slot=\"pagination-item\">Page</li>")}

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
    %{
      id: "docs-alert-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Delete project?"),
      description: slot("This action is irreversible."),
      inner_block: slot("Dialog body"),
      footer:
        slot("<button class=\"inline-flex h-8 rounded-md border px-3 text-xs\">Cancel</button>")
    }
  end

  defp sample_assigns(Overlay, :dialog) do
    %{
      id: "docs-dialog",
      open: false,
      trigger: slot("Open"),
      title: slot("Dialog title"),
      description: slot("Dialog description"),
      inner_block: slot("Dialog body"),
      footer:
        slot("<button class=\"inline-flex h-8 rounded-md border px-3 text-xs\">Done</button>")
    }
  end

  defp sample_assigns(Overlay, :drawer) do
    %{
      id: "docs-drawer",
      open: false,
      side: :right,
      trigger: slot("Open"),
      title: slot("Drawer"),
      description: slot("Drawer description"),
      inner_block: slot("Drawer body"),
      footer:
        slot("<button class=\"inline-flex h-8 rounded-md border px-3 text-xs\">Save</button>")
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
    %{
      menu: [
        %{
          label: "File",
          inner_block: fn _, _ ->
            "<button class=\"block w-full rounded-sm px-2 py-1 text-left text-sm\">New</button>"
          end
        }
      ]
    }
  end

  defp sample_assigns(Overlay, :popover) do
    %{id: "docs-popover", trigger: slot("Popover"), content: slot("Popover content")}
  end

  defp sample_assigns(Overlay, :sheet), do: sample_assigns(Overlay, :drawer)

  defp sample_assigns(Overlay, :tooltip),
    do: %{
      text: "Tooltip text",
      inner_block:
        slot("<button class=\"inline-flex h-8 rounded-md border px-3 text-xs\">Hover me</button>")
    }

  defp sample_assigns(Advanced, :calendar),
    do: %{
      inner_block: slot("<div class=\"text-sm text-muted-foreground\">Calendar container</div>")
    }

  defp sample_assigns(Advanced, :carousel) do
    %{
      id: "docs-carousel",
      item: [
        %{inner_block: fn _, _ -> "<div class=\"h-24 rounded-md bg-muted\"></div>" end},
        %{inner_block: fn _, _ -> "<div class=\"h-24 rounded-md bg-muted/60\"></div>" end}
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
    %{
      group: [
        %{
          heading: "General",
          inner_block: fn _, _ ->
            "<div data-slot=\"item\" class=\"rounded-sm px-2 py-1.5 text-sm\">Profile</div>"
          end
        }
      ]
    }
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

  defp slot(content), do: [%{inner_block: fn _, _ -> Phoenix.HTML.raw(content) end}]
end
