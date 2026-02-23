defmodule Mix.Tasks.CinderUi.Docs.Build do
  @shortdoc "Builds a static Cinder UI docs site"
  @moduledoc """
  Builds a static HTML/CSS/JS docs site for Cinder UI components.

  Output can be deployed to any static host (GitHub Pages, Netlify, S3, etc)
  without running Phoenix/Elixir on the server.

  ## Options

    * `--output` - output directory (default: `dist/docs`)
    * `--clean` - remove output directory before generating
    * `--home-url` - optional link target for a parent site home page
    * `--github-url` - repository URL shown in docs header
    * `--hex-package-url` - Hex package URL shown in docs header

  ## Examples

      mix cinder_ui.docs.build
      mix cinder_ui.docs.build --output public/docs --clean
  """

  use Mix.Task

  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Docs.Catalog
  alias CinderUI.Icons
  alias Phoenix.HTML
  alias Phoenix.HTML.Safe

  @impl true
  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [
          output: :string,
          clean: :boolean,
          home_url: :string,
          github_url: :string,
          hex_package_url: :string,
          help: :boolean
        ]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
    else
      output_dir = Path.expand(opts[:output] || "dist/docs", File.cwd!())
      clean? = opts[:clean] || false
      project = Mix.Project.config()
      home_url = opts[:home_url]
      github_url = opts[:github_url] || to_string(project[:source_url] || "")
      hex_package_url = opts[:hex_package_url] || "https://hex.pm/packages/cinder_ui"

      if clean? and File.dir?(output_dir), do: File.rm_rf!(output_dir)

      assets_dir = Path.join(output_dir, "assets")
      File.mkdir_p!(assets_dir)

      theme_css = theme_css()
      sections = Catalog.sections()
      entries = Enum.flat_map(sections, & &1.entries)

      File.write!(
        Path.join(output_dir, "index.html"),
        overview_page_html(sections, theme_css, home_url, github_url, hex_package_url)
      )

      Enum.each(entries, fn entry ->
        output_path = Path.join(output_dir, entry.docs_path)
        File.mkdir_p!(Path.dirname(output_path))

        File.write!(
          output_path,
          component_page_html(entry, sections, theme_css, home_url, github_url, hex_package_url)
        )
      end)

      File.write!(Path.join(assets_dir, "site.js"), site_js())
      File.write!(Path.join(assets_dir, "site.css"), site_css())

      Mix.shell().info("generated #{relative(output_dir)}")
      Mix.shell().info("entries: #{Catalog.entry_count()}")
      Mix.shell().info("open #{relative(Path.join(output_dir, "index.html"))} in a browser")
    end
  end

  defp theme_css do
    "assets/css/cinder_ui.css"
    |> File.read!()
    |> String.replace(~r/^@import\s+"tailwindcss";\n?/m, "")
    |> String.replace(~r/^@plugin\s+"tailwindcss-animate";\n?/m, "")
  end

  defp overview_page_html(sections, theme_css, home_url, github_url, hex_package_url) do
    content = """
    <section class=\"mb-8\">
      <h2 class=\"text-2xl font-semibold tracking-tight\">Component Library</h2>
      <p class=\"text-muted-foreground mt-2 max-w-3xl text-sm\">
        Static docs for Cinder UI components. Open any component for preview, HEEx usage,
        generated attributes/slots docs, and a link to the original shadcn/ui reference.
      </p>
    </section>

    #{overview_sections_html(sections)}
    """

    page_shell(
      title: "Cinder UI Docs",
      description: "Static component docs for Cinder UI",
      body_content: content,
      theme_css: theme_css,
      asset_prefix: ".",
      sidebar: sidebar_links(sections, ".", nil),
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp component_page_html(entry, sections, theme_css, home_url, github_url, hex_package_url) do
    examples_html = component_examples_html(entry)

    content = """
    <div class=\"mb-6 flex flex-wrap items-center justify-between gap-3\">
      <a href=\"../index.html##{section_id_for_entry(sections, entry.id)}\" class=\"inline-flex items-center rounded-md border px-3 py-1.5 text-xs hover:bg-accent\">← Back to index</a>
      <a href=\"#{entry.shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"inline-flex items-center rounded-md border px-3 py-1.5 text-xs hover:bg-accent\">Original shadcn/ui docs ↗</a>
    </div>

    <section class=\"mb-6\">
      <p class=\"text-muted-foreground text-xs\">#{entry.module_name}</p>
      <h2 class=\"mt-1 text-2xl font-semibold tracking-tight\"><code>#{entry.module_name}.#{entry.title}</code></h2>
      <p class=\"text-muted-foreground mt-3 text-sm\">#{inline_code_html(entry.docs)}</p>
    </section>

    <section class=\"mb-8 space-y-4\">
      #{examples_html}
    </section>

    <section class=\"mb-6\">
      <h3 class=\"mb-3 text-sm font-semibold\">Attributes</h3>
      #{attributes_table_html(entry.attributes)}
    </section>

    <section class=\"mb-6\">
      <h3 class=\"mb-3 text-sm font-semibold\">Slots</h3>
      #{slots_table_html(entry.slots)}
    </section>

    #{function_docs_panel_html(entry.docs_full, entry.docs)}
    """

    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: content,
      theme_css: theme_css,
      asset_prefix: "..",
      sidebar: sidebar_links(sections, "..", entry.id),
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp page_shell(opts) do
    title = opts[:title]
    description = opts[:description]
    body_content = opts[:body_content]
    theme_css = opts[:theme_css]
    asset_prefix = opts[:asset_prefix]
    sidebar = opts[:sidebar]
    home_url = opts[:home_url]
    github_url = opts[:github_url]
    hex_package_url = opts[:hex_package_url]

    """
    <!doctype html>
    <html lang=\"en\">
      <head>
        <meta charset=\"utf-8\" />
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
        <title>#{escape(title)}</title>
        <meta name=\"description\" content=\"#{escape(description)}\" />
        <script src=\"https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4\"></script>
        <style type=\"text/tailwindcss\">
    #{theme_css}

    @layer base {
      body {
        @apply min-h-screen;
      }
    }
        </style>
        <link rel=\"stylesheet\" href=\"#{asset_prefix}/assets/site.css\" />
      </head>
      <body class=\"bg-background text-foreground\">
        <div class=\"mx-auto grid min-h-screen max-w-[1900px] grid-cols-1 lg:grid-cols-[320px_1fr]\">
          <aside class=\"border-border/70 sticky top-0 h-screen overflow-y-auto border-r px-5 py-6\">
            <div class=\"mb-6\">
              <h1 class=\"text-xl font-semibold\">Cinder UI</h1>
              <p class=\"text-muted-foreground mt-1 text-sm\">Static component docs</p>
              #{header_links_html(home_url, github_url, hex_package_url)}
            </div>

            #{theme_controls_html()}

            <nav class=\"space-y-4\" aria-label=\"Component sections\">
              #{sidebar}
            </nav>

            <div class=\"mt-6 text-xs text-muted-foreground\">
              Generated by <code>mix cinder_ui.docs.build</code>
            </div>
          </aside>

          <main class=\"px-5 py-6 lg:px-8\">
            #{body_content}
          </main>
        </div>

        <script src=\"#{asset_prefix}/assets/site.js\"></script>
      </body>
    </html>
    """
  end

  defp sidebar_links(sections, root_prefix, active_entry_id) do
    index_href = "#{root_prefix}/index.html"
    overview_active? = is_nil(active_entry_id)

    section_blocks =
      Enum.map_join(sections, "\n", fn section ->
        entries =
          Enum.map_join(
            section.entries,
            "\n",
            &sidebar_entry_html(&1, root_prefix, active_entry_id)
          )

        """
        <div>
          <a href=\"#{index_href}##{section.id}\" class=\"sidebar-section-link text-sm font-semibold\">#{section.title}</a>
          <ul class=\"mt-2 space-y-1\">#{entries}</ul>
        </div>
        """
      end)

    """
    <div>
      <a href=\"#{index_href}\" class=\"#{sidebar_link_class(overview_active?)}\"#{current_page_attr(overview_active?)}>Overview</a>
    </div>
    #{section_blocks}
    """
  end

  defp sidebar_entry_html(entry, root_prefix, active_entry_id) do
    active? = entry.id == active_entry_id
    active_class = sidebar_link_class(active?)

    """
    <li>
      <a class=\"#{active_class}\" href=\"#{root_prefix}/#{entry.docs_path}\"#{current_page_attr(active?)}>#{entry.title}</a>
    </li>
    """
  end

  defp current_page_attr(true), do: ~s( aria-current="page")
  defp current_page_attr(false), do: ""

  defp header_links_html(home_url, github_url, hex_package_url) do
    links =
      [
        if(is_binary(home_url) and home_url != "",
          do:
            ~s(<a href="#{escape(home_url)}" class="inline-flex items-center rounded-md border px-2 py-1 hover:bg-accent">Home</a>)
        ),
        if(is_binary(github_url) and github_url != "",
          do:
            ~s(<a href="#{escape(github_url)}" target="_blank" rel="noopener noreferrer" class="inline-flex items-center rounded-md border px-2 py-1 hover:bg-accent">GitHub</a>)
        ),
        if(is_binary(hex_package_url) and hex_package_url != "",
          do:
            ~s(<a href="#{escape(hex_package_url)}" target="_blank" rel="noopener noreferrer" class="inline-flex items-center rounded-md border px-2 py-1 hover:bg-accent">Hex package</a>)
        )
      ]
      |> Enum.reject(&is_nil/1)

    if links == [] do
      ""
    else
      ~s(<div class="mt-3 flex flex-wrap gap-1 text-xs">#{Enum.join(links, "")}</div>)
    end
  end

  defp theme_controls_html do
    color_select =
      render_component(Forms, :select, %{
        name: "theme-color",
        value: "neutral",
        option: select_options(["zinc", "slate", "stone", "gray", "neutral"]),
        class: "h-8 text-xs",
        rest: %{"id" => "theme-color", "aria-label" => "Theme color"}
      })

    radius_select =
      render_component(Forms, :select, %{
        name: "theme-radius",
        value: "nova",
        option:
          select_entries([
            {"maia", "Compact (6px / 0.375rem)"},
            {"mira", "Small (8px / 0.5rem)"},
            {"nova", "Default (12px / 0.75rem)"},
            {"lyra", "Large (14px / 0.875rem)"},
            {"vega", "XL (16px / 1rem)"}
          ]),
        class: "h-8 text-xs",
        rest: %{"id" => "theme-radius", "aria-label" => "Theme radius"}
      })

    """
    <section class=\"mb-6 rounded-lg border p-3\">
      <h2 class=\"text-sm font-semibold\">Theme</h2>

      <div class=\"mt-3\">
        <p class=\"mb-2 text-xs font-medium text-muted-foreground\">Mode</p>
        <div class=\"grid grid-cols-3 gap-1\">
          <button type=\"button\" data-theme-mode=\"light\" class=\"theme-mode-btn inline-flex h-8 items-center justify-center rounded-md border px-2 text-xs\">Light</button>
          <button type=\"button\" data-theme-mode=\"dark\" class=\"theme-mode-btn inline-flex h-8 items-center justify-center rounded-md border px-2 text-xs\">Dark</button>
          <button type=\"button\" data-theme-mode=\"auto\" class=\"theme-mode-btn inline-flex h-8 items-center justify-center rounded-md border px-2 text-xs\">Auto</button>
        </div>
      </div>

      <div class=\"mt-3\">
        <label for=\"theme-color\" class=\"mb-2 block text-xs font-medium text-muted-foreground\">Color</label>
        #{color_select}
      </div>

      <div class=\"mt-3\">
        <label for=\"theme-radius\" class=\"mb-2 block text-xs font-medium text-muted-foreground\">Radius</label>
        #{radius_select}
      </div>
    </section>
    """
  end

  defp select_options(options) do
    Enum.map(options, fn option ->
      %{value: option, label: option |> String.replace("_", " ") |> String.capitalize()}
    end)
  end

  defp select_entries(options) do
    Enum.map(options, fn {value, label} -> %{value: value, label: label} end)
  end

  defp overview_sections_html(sections) do
    Enum.map_join(sections, "\n", fn section ->
      entries = Enum.map_join(section.entries, "\n", &overview_entry_html/1)

      """
      <section id=\"#{section.id}\" class=\"mb-12\">
        <h3 class=\"mb-4 text-xl font-semibold\">#{section.title}</h3>
        <div class=\"grid gap-4 xl:grid-cols-2 2xl:grid-cols-3\">#{entries}</div>
      </section>
      """
    end)
  end

  defp overview_entry_html(entry) do
    escaped_docs = inline_code_html(entry.docs)
    escaped_template = escape(entry.template_heex)

    """
    <article id=\"#{entry.id}\" data-component-card data-component-name=\"#{entry.title}\" class=\"rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-4 py-3\">
        <div class=\"flex flex-wrap items-start justify-between gap-2\">
          <h4 class=\"font-medium\">
            <a href=\"./#{entry.docs_path}\" class=\"hover:underline underline-offset-4\">
              <code>#{entry.module_name}.#{entry.title}</code>
            </a>
          </h4>
          <div class=\"flex items-center gap-1\">
            <button type=\"button\" data-copy-template=\"#{entry.id}\" class=\"inline-flex h-7 items-center rounded-md border px-2 text-xs hover:bg-accent\">Copy HEEx</button>
            <a href=\"./#{entry.docs_path}\" class=\"inline-flex h-7 items-center rounded-md border px-2 text-xs hover:bg-accent\">Open docs</a>
          </div>
        </div>
        <p class=\"text-muted-foreground mt-2 text-sm\">#{escaped_docs}</p>
      </header>

      <div class=\"p-4\">
        <div class=\"rounded-lg border bg-background p-4\">#{entry.preview_html}</div>
        <div class=\"mt-3\">
          <h5 class=\"text-xs font-semibold\">Phoenix template (HEEx)</h5>
          <pre class=\"mt-2 max-h-56 overflow-auto rounded-md border bg-muted/30 p-3 text-xs\"><code id=\"code-#{entry.id}\">#{escaped_template}</code></pre>
        </div>
        <div class=\"mt-3 flex flex-wrap items-center justify-between gap-2 text-xs\">
          <span class=\"text-muted-foreground\">attrs: <span class=\"font-medium text-foreground\">#{length(entry.attributes)}</span> · slots: <span class=\"font-medium text-foreground\">#{length(entry.slots)}</span></span>
          <a href=\"#{entry.shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-muted-foreground hover:text-foreground underline underline-offset-4\">shadcn reference ↗</a>
        </div>
      </div>
    </article>
    """
  end

  defp component_examples_html(entry) do
    total = length(entry.examples)
    copy_icon_html = render_component(Icons, :icon, %{name: "copy", class: "size-3.5"})

    entry.examples
    |> Enum.with_index(1)
    |> Enum.map_join("\n", fn {example, index} ->
      copy_id = "#{entry.id}-#{example.id}"
      escaped_template = escape(example.template_heex)
      heading = example_heading(example.title, index, total)

      description =
        case example.description do
          value when is_binary(value) and value != "" ->
            ~s(<p class="text-muted-foreground mt-1 text-xs">#{escape(value)}</p>)

          _ ->
            ""
        end

      """
      <section class=\"mb-10\">
        <header>
          <h3 class=\"text-sm font-semibold\">#{escape(heading)}</h3>
          #{description}
        </header>

        <div data-slot=\"component-preview\" class=\"mt-4 overflow-hidden rounded-xl border\">
          <div data-slot=\"preview\" class=\"p-4 sm:p-6\">
            #{example.preview_html}
          </div>

          <div data-slot=\"code\" class=\"relative border-t bg-muted/20\">
            <button
              type=\"button\"
              data-copy-template=\"#{copy_id}\"
              aria-label=\"Copy HEEx\"
              title=\"Copy HEEx\"
              class=\"absolute top-2.5 right-2 z-10 inline-flex h-7 w-7 items-center justify-center rounded-md border bg-background/80 text-xs hover:bg-accent hover:text-accent-foreground\"
            >#{copy_icon_html}</button>
            <pre class=\"max-h-96 overflow-auto bg-muted/30 p-4 text-xs\"><code id=\"code-#{copy_id}\">#{escaped_template}</code></pre>
          </div>
        </div>
      </section>
      """
    end)
  end

  defp example_heading("Default", 1, 1), do: "Example"
  defp example_heading(title, _index, _total), do: title

  defp docs_full_html(doc) do
    case Earmark.as_html(doc, compact_output: true) do
      {:ok, html, _messages} ->
        "<article class=\"docs-markdown\">#{sanitize_docs_html(html)}</article>"

      {:error, html, _messages} ->
        "<article class=\"docs-markdown\">#{sanitize_docs_html(html)}</article>"
    end
  rescue
    _ ->
      escaped_doc = escape(doc)
      "<article class=\"docs-markdown\"><p>#{escaped_doc}</p></article>"
  end

  defp function_docs_panel_html(docs_full, summary) do
    residual = docs_residual(docs_full, summary)

    if residual == "" do
      ""
    else
      """
      <section class=\"mb-6\">
        <h3 class=\"mb-3 text-sm font-semibold\">Function Docs</h3>
        <div class=\"space-y-3 text-sm\">
          #{docs_full_html(residual)}
        </div>
      </section>
      """
    end
  end

  defp docs_residual(doc, summary) do
    doc
    |> String.trim()
    |> maybe_strip_leading_summary(summary)
    |> strip_markdown_sections(
      ~w(example examples attribute attributes slot slots usage variant variants)
    )
    |> String.trim()
  end

  defp maybe_strip_leading_summary(doc, summary) when is_binary(summary) and summary != "" do
    String.replace(doc, ~r/\A#{Regex.escape(summary)}\s*\n*/u, "")
  end

  defp maybe_strip_leading_summary(doc, _summary), do: doc

  defp strip_markdown_sections(doc, headings) do
    Enum.reduce(headings, doc, fn heading, acc ->
      pattern = ~r/(?:^|\n)##+\s+#{heading}\b[\s\S]*?(?=\n##+\s|\z)/mi
      String.replace(acc, pattern, "\n")
    end)
  end

  defp sanitize_docs_html(html) do
    html
    |> String.replace(~r/<script\b[^>]*>.*?<\/script>/is, "")
    |> String.replace(~r/<style\b[^>]*>.*?<\/style>/is, "")
  end

  defp inline_code_html(text) do
    text
    |> String.split(~r/(`[^`\n]+`)/, include_captures: true, trim: false)
    |> Enum.map_join(&inline_code_segment_html/1)
  end

  defp inline_code_segment_html(""), do: ""

  defp inline_code_segment_html(segment) do
    if String.starts_with?(segment, "`") and String.ends_with?(segment, "`") and
         String.length(segment) > 1 do
      code =
        segment
        |> String.trim_leading("`")
        |> String.trim_trailing("`")

      ~s(<code class="inline-code">#{escape(code)}</code>)
    else
      escape(segment)
    end
  end

  defp attributes_table_html([]) do
    "<p class=\"text-sm text-muted-foreground\">No attributes declared.</p>"
  end

  defp attributes_table_html(attrs) do
    rows =
      Enum.map_join(attrs, "\n", fn attr ->
        values =
          if attr.values == [] do
            "—"
          else
            Enum.map_join(attr.values, ", ", &"<code>#{escape(inspect(&1))}</code>")
          end

        includes =
          if attr.includes == [] do
            "—"
          else
            Enum.map_join(attr.includes, ", ", &"<code>#{escape(&1)}</code>")
          end

        default =
          if is_nil(attr.default) do
            "—"
          else
            "<code>#{escape(inspect(attr.default))}</code>"
          end

        name =
          "<code>#{attr.name}</code>" <>
            if(attr.required, do: required_badge_html("ml-2"), else: "")

        """
        <tr class=\"border-border/60 border-t align-top\">
          <td class=\"px-3 py-2\">#{name}</td>
          <td class=\"px-3 py-2\"><code>#{escape(attr.type)}</code></td>
          <td class=\"px-3 py-2\">#{default}</td>
          <td class=\"px-3 py-2\">#{values}</td>
          <td class=\"px-3 py-2\">#{includes}</td>
        </tr>
        """
      end)

    """
    <div class=\"overflow-auto rounded-md border\">
      <table class=\"w-full min-w-[680px] text-left text-xs\">
        <thead class=\"bg-muted/40\">
          <tr>
            <th class=\"px-3 py-2 font-medium\">Name</th>
            <th class=\"px-3 py-2 font-medium\">Type</th>
            <th class=\"px-3 py-2 font-medium\">Default</th>
            <th class=\"px-3 py-2 font-medium\">Values</th>
            <th class=\"px-3 py-2 font-medium\">Global Includes</th>
          </tr>
        </thead>
        <tbody>#{rows}</tbody>
      </table>
    </div>
    """
  end

  defp slots_table_html([]) do
    "<p class=\"text-sm text-muted-foreground\">No slots declared.</p>"
  end

  defp slots_table_html(slots) do
    rows =
      Enum.map_join(slots, "\n", fn slot ->
        name =
          "<code>#{slot.name}</code>" <>
            if(slot.required, do: required_badge_html("ml-2"), else: "")

        slot_attrs = slot_attrs_summary(slot.attrs)

        """
        <tr class=\"border-border/60 border-t align-top\">
          <td class=\"px-3 py-2\">#{name}</td>
          <td class=\"px-3 py-2\">#{slot_attrs}</td>
        </tr>
        """
      end)

    """
    <div class=\"overflow-auto rounded-md border\">
      <table class=\"w-full min-w-[560px] text-left text-xs\">
        <thead class=\"bg-muted/40\">
          <tr>
            <th class=\"px-3 py-2 font-medium\">Slot</th>
            <th class=\"px-3 py-2 font-medium\">Slot Attributes</th>
          </tr>
        </thead>
        <tbody>#{rows}</tbody>
      </table>
    </div>
    """
  end

  defp section_id_for_entry(sections, entry_id) do
    Enum.find_value(sections, "actions", fn section ->
      if Enum.any?(section.entries, &(&1.id == entry_id)), do: section.id
    end)
  end

  defp sidebar_link_class(active?) do
    base = "sidebar-link block rounded-md px-2 py-1.5 text-sm transition-colors"

    if active? do
      "#{base} bg-accent text-accent-foreground font-medium"
    else
      "#{base} text-muted-foreground hover:bg-accent/50 hover:text-foreground"
    end
  end

  defp slot_attrs_summary([]), do: "—"

  defp slot_attrs_summary(attrs) do
    Enum.map_join(attrs, "<br/>", fn attr ->
      "<code>#{attr.name}</code> <span class=\"text-muted-foreground\">(#{escape(attr.type)})</span>" <>
        if(attr.required, do: required_badge_html("ml-1"), else: "")
    end)
  end

  defp required_badge_html(extra_class) do
    render_component(Feedback, :badge, %{
      variant: :destructive,
      class: "align-middle #{extra_class}",
      inner_block: [
        %{
          inner_block: fn _, _ -> HTML.raw("Required") end
        }
      ]
    })
  end

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp site_js, do: docs_asset!("site.js")
  defp site_css, do: docs_asset!("site.css")

  defp docs_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "docs", name])
    |> File.read!()
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
