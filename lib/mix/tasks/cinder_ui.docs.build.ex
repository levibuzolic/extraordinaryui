defmodule Mix.Tasks.CinderUi.Docs.Build do
  @shortdoc "Builds a static Cinder UI docs site"
  @moduledoc """
  Builds a static HTML/CSS/JS docs site for Cinder UI components.

  Output can be deployed to any static host (GitHub Pages, Netlify, S3, etc)
  without running Phoenix/Elixir on the server.

  ## Options

    * `--output` - output directory (default: `dist/docs`)
    * `--clean` - remove output directory before generating

  ## Examples

      mix cinder_ui.docs.build
      mix cinder_ui.docs.build --output public/docs --clean
  """

  use Mix.Task

  alias CinderUI.Components.Forms
  alias CinderUI.Docs.Catalog
  alias Phoenix.HTML
  alias Phoenix.HTML.Safe

  @impl true
  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [
          output: :string,
          clean: :boolean,
          help: :boolean
        ]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
    else
      output_dir = Path.expand(opts[:output] || "dist/docs", File.cwd!())
      clean? = opts[:clean] || false

      if clean? and File.dir?(output_dir), do: File.rm_rf!(output_dir)

      assets_dir = Path.join(output_dir, "assets")
      File.mkdir_p!(assets_dir)

      theme_css = theme_css()
      sections = Catalog.sections()
      entries = Enum.flat_map(sections, & &1.entries)

      File.write!(Path.join(output_dir, "index.html"), overview_page_html(sections, theme_css))

      Enum.each(entries, fn entry ->
        output_path = Path.join(output_dir, entry.docs_path)
        File.mkdir_p!(Path.dirname(output_path))
        File.write!(output_path, component_page_html(entry, sections, theme_css))
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

  defp overview_page_html(sections, theme_css) do
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
      sidebar: sidebar_links(sections, ".", nil)
    )
  end

  defp component_page_html(entry, sections, theme_css) do
    examples_html = component_examples_html(entry)
    inline_doc_examples_html = inline_doc_examples_html(entry)

    content = """
    <div class=\"mb-6 flex flex-wrap items-center justify-between gap-3\">
      <a href=\"../index.html##{section_id_for_entry(sections, entry.id)}\" class=\"inline-flex items-center rounded-md border px-3 py-1.5 text-xs hover:bg-accent\">← Back to index</a>
      <a href=\"#{entry.shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"inline-flex items-center rounded-md border px-3 py-1.5 text-xs hover:bg-accent\">Original shadcn/ui docs ↗</a>
    </div>

    <section class=\"mb-6 rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-5 py-4\">
        <p class=\"text-muted-foreground text-xs\">#{entry.module_name}</p>
        <h2 class=\"mt-1 text-2xl font-semibold tracking-tight\"><code>#{entry.module_name}.#{entry.title}</code></h2>
        <p class=\"text-muted-foreground mt-3 text-sm\">#{inline_code_html(entry.docs)}</p>
      </header>
      <div class=\"space-y-4 p-5\">#{examples_html}</div>
    </section>

    <section class=\"mb-6 rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-5 py-3\">
        <h3 class=\"text-sm font-semibold\">Attributes</h3>
      </header>
      <div class=\"p-5\">
        #{attributes_table_html(entry.attributes)}
      </div>
    </section>

    <section class=\"mb-6 rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-5 py-3\">
        <h3 class=\"text-sm font-semibold\">Slots</h3>
      </header>
      <div class=\"p-5\">
        #{slots_table_html(entry.slots)}
      </div>
    </section>

    <section class=\"rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-5 py-3\">
        <h3 class=\"text-sm font-semibold\">Function Docs</h3>
      </header>
      <div class=\"space-y-3 p-5 text-sm\">
        #{docs_full_html(entry.docs_full)}
      </div>
    </section>

    #{inline_doc_examples_html}
    """

    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: content,
      theme_css: theme_css,
      asset_prefix: "..",
      sidebar: sidebar_links(sections, "..", entry.id)
    )
  end

  defp page_shell(opts) do
    title = opts[:title]
    description = opts[:description]
    body_content = opts[:body_content]
    theme_css = opts[:theme_css]
    asset_prefix = opts[:asset_prefix]
    sidebar = opts[:sidebar]

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

  defp theme_controls_html do
    color_select =
      render_component(Forms, :native_select, %{
        name: "theme-color",
        value: "neutral",
        option: native_select_options(["zinc", "slate", "stone", "gray", "neutral"]),
        class: "h-8 text-xs",
        rest: %{"id" => "theme-color", "aria-label" => "Theme color"}
      })

    radius_select =
      render_component(Forms, :native_select, %{
        name: "theme-radius",
        value: "nova",
        option: native_select_options(["maia", "mira", "nova", "lyra", "vega"]),
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

  defp native_select_options(options) do
    Enum.map(options, fn option ->
      %{value: option, label: option |> String.replace("_", " ") |> String.capitalize()}
    end)
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
      <article class=\"rounded-lg border bg-muted/20 p-4\">
        <header class=\"mb-3\">
          <h3 class=\"text-sm font-semibold\">#{escape(heading)}</h3>
          #{description}
        </header>

        <div>
          <h4 class=\"text-sm font-semibold\">Preview</h4>
          <div class=\"mt-2 rounded-lg border bg-background p-4\">#{example.preview_html}</div>
        </div>

        <div class=\"mt-4\">
          <div class=\"flex items-center justify-between gap-2\">
            <h4 class=\"text-sm font-semibold\">Usage (HEEx)</h4>
            <button type=\"button\" data-copy-template=\"#{copy_id}\" class=\"inline-flex h-7 items-center rounded-md border px-2 text-xs hover:bg-accent\">Copy HEEx</button>
          </div>
          <pre class=\"mt-2 max-h-96 overflow-auto rounded-md border bg-muted/30 p-4 text-xs\"><code id=\"code-#{copy_id}\">#{escaped_template}</code></pre>
        </div>
      </article>
      """
    end)
  end

  defp example_heading("Default", 1, 1), do: "Example"
  defp example_heading(title, _index, _total), do: title

  defp inline_doc_examples_html(%{inline_doc_examples: []}), do: ""

  defp inline_doc_examples_html(entry) do
    blocks =
      entry.inline_doc_examples
      |> Enum.map_join("\n", fn example ->
        copy_id = "#{entry.id}-#{example.id}"
        escaped_template = escape(example.template_heex)

        """
        <article class=\"rounded-lg border bg-muted/20 p-4\">
          <div class=\"flex items-center justify-between gap-2\">
            <h4 class=\"text-sm font-semibold\">#{escape(example.title)}</h4>
            <button type=\"button\" data-copy-template=\"#{copy_id}\" class=\"inline-flex h-7 items-center rounded-md border px-2 text-xs hover:bg-accent\">Copy HEEx</button>
          </div>
          <pre class=\"mt-2 max-h-96 overflow-auto rounded-md border bg-muted/30 p-4 text-xs\"><code id=\"code-#{copy_id}\">#{escaped_template}</code></pre>
        </article>
        """
      end)

    """
    <section class=\"mt-6 rounded-xl border bg-card text-card-foreground shadow-sm\">
      <header class=\"border-border/70 border-b px-5 py-3\">
        <h3 class=\"text-sm font-semibold\">Inline Docs Examples</h3>
      </header>
      <div class=\"space-y-3 p-5\">
        <p class=\"text-muted-foreground text-sm\">Rendered from fenced code blocks in the component's inline <code class="inline-code">@doc</code>.</p>
        #{blocks}
      </div>
    </section>
    """
  end

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

        """
        <tr class=\"border-border/60 border-t align-top\">
          <td class=\"px-3 py-2\"><code>#{attr.name}</code></td>
          <td class=\"px-3 py-2\"><code>#{escape(attr.type)}</code></td>
          <td class=\"px-3 py-2\">#{if(attr.required, do: "yes", else: "no")}</td>
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
            <th class=\"px-3 py-2 font-medium\">Required</th>
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
        slot_attrs = slot_attrs_summary(slot.attrs)

        """
        <tr class=\"border-border/60 border-t align-top\">
          <td class=\"px-3 py-2\"><code>#{slot.name}</code></td>
          <td class=\"px-3 py-2\">#{if(slot.required, do: "yes", else: "no")}</td>
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
            <th class=\"px-3 py-2 font-medium\">Required</th>
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
      "<code>#{attr.name}</code> <span class=\"text-muted-foreground\">(#{escape(attr.type)})</span>"
    end)
  end

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp site_js do
    """
    (() => {
      const qs = (root, selector) => Array.from(root.querySelectorAll(selector))
      const escapeHtml = (value) =>
        value
          .replace(/&/g, "&amp;")
          .replace(/</g, "&lt;")
          .replace(/>/g, "&gt;")
      const toggleVisibility = (el, visible) => {
        if (!el) return
        el.classList.toggle("hidden", !visible)
        el.dataset.state = visible ? "open" : "closed"
      }
      const highlightHeex = (source) => {
        let html = escapeHtml(source)
        html = html.replace(/(&lt;!--[\\s\\S]*?--&gt;)/g, '<span class="tok-comment">$1</span>')
        html = html.replace(/(&lt;\\/?)([:A-Za-z0-9_.-]+)/g, '$1<span class="tok-tag">$2</span>')
        html = html.replace(/([:@A-Za-z0-9_-]+)(=)/g, '<span class="tok-attr">$1</span>$2')
        html = html.replace(/(&quot;[^&]*?&quot;)/g, '<span class="tok-string">$1</span>')
        html = html.replace(/(\\{[^\\n]*?\\})/g, '<span class="tok-expr">$1</span>')
        html = html.replace(/\\b(true|false|nil|do|end)\\b/g, '<span class="tok-keyword">$1</span>')
        return html
      }
      const highlightCodeBlocks = () => {
        qs(document, "pre code").forEach((block) => {
          if (block.dataset.highlighted === "true") return
          const source = block.textContent || ""
          if (source.trim() === "") return

          const isHeexLike =
            source.includes("<.") || source.includes("</.") || source.includes("<:")

          block.innerHTML = isHeexLike ? highlightHeex(source) : escapeHtml(source)
          block.classList.add("code-highlight")
          block.dataset.highlighted = "true"
        })
      }
      const themeStorage = {
        mode: "eui:theme:mode",
        color: "eui:theme:color",
        radius: "eui:theme:radius",
      }
      const themePresets = {
        zinc: {
          light: {
            foreground: "oklch(0.141 0.005 285.823)",
            card: "oklch(1 0 0)",
            "card-foreground": "oklch(0.141 0.005 285.823)",
            popover: "oklch(1 0 0)",
            "popover-foreground": "oklch(0.141 0.005 285.823)",
            primary: "oklch(0.21 0.006 285.885)",
            "primary-foreground": "oklch(0.985 0 0)",
            secondary: "oklch(0.967 0.001 286.375)",
            "secondary-foreground": "oklch(0.21 0.006 285.885)",
            muted: "oklch(0.967 0.001 286.375)",
            "muted-foreground": "oklch(0.552 0.016 285.938)",
            accent: "oklch(0.967 0.001 286.375)",
            "accent-foreground": "oklch(0.21 0.006 285.885)",
            border: "oklch(0.92 0.004 286.32)",
            input: "oklch(0.92 0.004 286.32)",
            ring: "oklch(0.705 0.015 286.067)",
          },
          dark: {
            background: "oklch(0.141 0.005 285.823)",
            foreground: "oklch(0.985 0 0)",
            card: "oklch(0.21 0.006 285.885)",
            "card-foreground": "oklch(0.985 0 0)",
            popover: "oklch(0.21 0.006 285.885)",
            "popover-foreground": "oklch(0.985 0 0)",
            primary: "oklch(0.92 0.004 286.32)",
            "primary-foreground": "oklch(0.21 0.006 285.885)",
            secondary: "oklch(0.274 0.006 286.033)",
            "secondary-foreground": "oklch(0.985 0 0)",
            muted: "oklch(0.274 0.006 286.033)",
            "muted-foreground": "oklch(0.705 0.015 286.067)",
            accent: "oklch(0.274 0.006 286.033)",
            "accent-foreground": "oklch(0.985 0 0)",
            border: "oklch(1 0 0 / 10%)",
            input: "oklch(1 0 0 / 15%)",
            ring: "oklch(0.552 0.016 285.938)",
          },
        },
        slate: {
          light: {
            foreground: "oklch(0.129 0.042 264.695)",
            card: "oklch(1 0 0)",
            "card-foreground": "oklch(0.129 0.042 264.695)",
            popover: "oklch(1 0 0)",
            "popover-foreground": "oklch(0.129 0.042 264.695)",
            primary: "oklch(0.208 0.042 265.755)",
            "primary-foreground": "oklch(0.984 0.003 247.858)",
            secondary: "oklch(0.968 0.007 247.896)",
            "secondary-foreground": "oklch(0.208 0.042 265.755)",
            muted: "oklch(0.968 0.007 247.896)",
            "muted-foreground": "oklch(0.554 0.046 257.417)",
            accent: "oklch(0.968 0.007 247.896)",
            "accent-foreground": "oklch(0.208 0.042 265.755)",
            border: "oklch(0.929 0.013 255.508)",
            input: "oklch(0.929 0.013 255.508)",
            ring: "oklch(0.704 0.04 256.788)",
          },
          dark: {
            background: "oklch(0.129 0.042 264.695)",
            foreground: "oklch(0.984 0.003 247.858)",
            card: "oklch(0.208 0.042 265.755)",
            "card-foreground": "oklch(0.984 0.003 247.858)",
            popover: "oklch(0.208 0.042 265.755)",
            "popover-foreground": "oklch(0.984 0.003 247.858)",
            primary: "oklch(0.929 0.013 255.508)",
            "primary-foreground": "oklch(0.208 0.042 265.755)",
            secondary: "oklch(0.279 0.041 260.031)",
            "secondary-foreground": "oklch(0.984 0.003 247.858)",
            muted: "oklch(0.279 0.041 260.031)",
            "muted-foreground": "oklch(0.704 0.04 256.788)",
            accent: "oklch(0.279 0.041 260.031)",
            "accent-foreground": "oklch(0.984 0.003 247.858)",
            border: "oklch(1 0 0 / 10%)",
            input: "oklch(1 0 0 / 15%)",
            ring: "oklch(0.551 0.027 264.364)",
          },
        },
        stone: {
          light: {
            foreground: "oklch(0.147 0.004 49.25)",
            card: "oklch(1 0 0)",
            "card-foreground": "oklch(0.147 0.004 49.25)",
            popover: "oklch(1 0 0)",
            "popover-foreground": "oklch(0.147 0.004 49.25)",
            primary: "oklch(0.216 0.006 56.043)",
            "primary-foreground": "oklch(0.985 0.001 106.423)",
            secondary: "oklch(0.97 0.001 106.424)",
            "secondary-foreground": "oklch(0.216 0.006 56.043)",
            muted: "oklch(0.97 0.001 106.424)",
            "muted-foreground": "oklch(0.553 0.013 58.071)",
            accent: "oklch(0.97 0.001 106.424)",
            "accent-foreground": "oklch(0.216 0.006 56.043)",
            border: "oklch(0.923 0.003 48.717)",
            input: "oklch(0.923 0.003 48.717)",
            ring: "oklch(0.709 0.01 56.259)",
          },
          dark: {
            background: "oklch(0.147 0.004 49.25)",
            foreground: "oklch(0.985 0.001 106.423)",
            card: "oklch(0.216 0.006 56.043)",
            "card-foreground": "oklch(0.985 0.001 106.423)",
            popover: "oklch(0.216 0.006 56.043)",
            "popover-foreground": "oklch(0.985 0.001 106.423)",
            primary: "oklch(0.923 0.003 48.717)",
            "primary-foreground": "oklch(0.216 0.006 56.043)",
            secondary: "oklch(0.268 0.007 34.298)",
            "secondary-foreground": "oklch(0.985 0.001 106.423)",
            muted: "oklch(0.268 0.007 34.298)",
            "muted-foreground": "oklch(0.709 0.01 56.259)",
            accent: "oklch(0.268 0.007 34.298)",
            "accent-foreground": "oklch(0.985 0.001 106.423)",
            border: "oklch(1 0 0 / 10%)",
            input: "oklch(1 0 0 / 15%)",
            ring: "oklch(0.553 0.013 58.071)",
          },
        },
        gray: {
          light: {
            foreground: "oklch(0.13 0.028 261.692)",
            card: "oklch(1 0 0)",
            "card-foreground": "oklch(0.13 0.028 261.692)",
            popover: "oklch(1 0 0)",
            "popover-foreground": "oklch(0.13 0.028 261.692)",
            primary: "oklch(0.21 0.034 264.665)",
            "primary-foreground": "oklch(0.985 0.002 247.839)",
            secondary: "oklch(0.967 0.003 264.542)",
            "secondary-foreground": "oklch(0.21 0.034 264.665)",
            muted: "oklch(0.967 0.003 264.542)",
            "muted-foreground": "oklch(0.551 0.027 264.364)",
            accent: "oklch(0.967 0.003 264.542)",
            "accent-foreground": "oklch(0.21 0.034 264.665)",
            border: "oklch(0.928 0.006 264.531)",
            input: "oklch(0.928 0.006 264.531)",
            ring: "oklch(0.707 0.022 261.325)",
          },
          dark: {
            background: "oklch(0.13 0.028 261.692)",
            foreground: "oklch(0.985 0.002 247.839)",
            card: "oklch(0.21 0.034 264.665)",
            "card-foreground": "oklch(0.985 0.002 247.839)",
            popover: "oklch(0.21 0.034 264.665)",
            "popover-foreground": "oklch(0.985 0.002 247.839)",
            primary: "oklch(0.928 0.006 264.531)",
            "primary-foreground": "oklch(0.21 0.034 264.665)",
            secondary: "oklch(0.278 0.033 256.848)",
            "secondary-foreground": "oklch(0.985 0.002 247.839)",
            muted: "oklch(0.278 0.033 256.848)",
            "muted-foreground": "oklch(0.707 0.022 261.325)",
            accent: "oklch(0.278 0.033 256.848)",
            "accent-foreground": "oklch(0.985 0.002 247.839)",
            border: "oklch(1 0 0 / 10%)",
            input: "oklch(1 0 0 / 15%)",
            ring: "oklch(0.551 0.027 264.364)",
          },
        },
        neutral: {
          light: {
            foreground: "oklch(0.145 0 0)",
            card: "oklch(1 0 0)",
            "card-foreground": "oklch(0.145 0 0)",
            popover: "oklch(1 0 0)",
            "popover-foreground": "oklch(0.145 0 0)",
            primary: "oklch(0.205 0 0)",
            "primary-foreground": "oklch(0.985 0 0)",
            secondary: "oklch(0.97 0 0)",
            "secondary-foreground": "oklch(0.205 0 0)",
            muted: "oklch(0.97 0 0)",
            "muted-foreground": "oklch(0.556 0 0)",
            accent: "oklch(0.97 0 0)",
            "accent-foreground": "oklch(0.205 0 0)",
            border: "oklch(0.922 0 0)",
            input: "oklch(0.922 0 0)",
            ring: "oklch(0.708 0 0)",
          },
          dark: {
            background: "oklch(0.145 0 0)",
            foreground: "oklch(0.985 0 0)",
            card: "oklch(0.205 0 0)",
            "card-foreground": "oklch(0.985 0 0)",
            popover: "oklch(0.205 0 0)",
            "popover-foreground": "oklch(0.985 0 0)",
            primary: "oklch(0.922 0 0)",
            "primary-foreground": "oklch(0.205 0 0)",
            secondary: "oklch(0.269 0 0)",
            "secondary-foreground": "oklch(0.985 0 0)",
            muted: "oklch(0.269 0 0)",
            "muted-foreground": "oklch(0.708 0 0)",
            accent: "oklch(0.269 0 0)",
            "accent-foreground": "oklch(0.985 0 0)",
            border: "oklch(1 0 0 / 10%)",
            input: "oklch(1 0 0 / 15%)",
            ring: "oklch(0.556 0 0)",
          },
        },
      }
      const radiusPresets = {
        maia: "0.375rem",
        mira: "0.5rem",
        nova: "0.75rem",
        lyra: "0.875rem",
        vega: "1rem",
      }
      const themedTokenKeys = Array.from(
        new Set(
          Object.values(themePresets).flatMap((palette) =>
            Object.values(palette).flatMap((modeTokens) => Object.keys(modeTokens))
          )
        )
      )
      const media = window.matchMedia("(prefers-color-scheme: dark)")
      const root = document.documentElement
      const modeButtons = qs(document, "[data-theme-mode]")
      const colorSelect = document.getElementById("theme-color")
      const radiusSelect = document.getElementById("theme-radius")

      const readSetting = (key, fallback) => localStorage.getItem(key) || fallback
      const writeSetting = (key, value) => localStorage.setItem(key, value)
      const resolveMode = (mode) => (mode === "auto" ? (media.matches ? "dark" : "light") : mode)

      const applyPalette = (color, resolvedMode) => {
        const palette = themePresets[color] || themePresets.neutral
        const tokens = palette[resolvedMode]
        themedTokenKeys.forEach((token) => {
          root.style.removeProperty(`--${token}`)
        })
        Object.entries(tokens).forEach(([token, value]) => {
          root.style.setProperty(`--${token}`, value)
        })
      }

      const syncThemeControls = (mode, color, radius) => {
        modeButtons.forEach((button) => {
          const active = button.dataset.themeMode === mode
          button.dataset.active = active ? "true" : "false"
          button.setAttribute("aria-pressed", active ? "true" : "false")
        })

        if (colorSelect) colorSelect.value = color
        if (radiusSelect) radiusSelect.value = radius
      }

      const applyTheme = () => {
        const mode = readSetting(themeStorage.mode, "auto")
        const color = readSetting(themeStorage.color, "neutral")
        const radius = readSetting(themeStorage.radius, "nova")
        const resolvedMode = resolveMode(mode)
        root.classList.toggle("dark", resolvedMode === "dark")
        applyPalette(color, resolvedMode)
        root.style.setProperty("--radius", radiusPresets[radius] || radiusPresets.nova)
        syncThemeControls(mode, color, radius)
      }

      modeButtons.forEach((button) => {
        button.addEventListener("click", () => {
          writeSetting(themeStorage.mode, button.dataset.themeMode || "auto")
          applyTheme()
        })
      })

      colorSelect?.addEventListener("change", () => {
        writeSetting(themeStorage.color, colorSelect.value)
        applyTheme()
      })

      radiusSelect?.addEventListener("change", () => {
        writeSetting(themeStorage.radius, radiusSelect.value)
        applyTheme()
      })

      if (typeof media.addEventListener === "function") {
        media.addEventListener("change", () => {
          if (readSetting(themeStorage.mode, "auto") === "auto") applyTheme()
        })
      }

      applyTheme()
      highlightCodeBlocks()

      const copyButtons = Array.from(document.querySelectorAll("[data-copy-template]"))
      copyButtons.forEach((button) => {
        button.addEventListener("click", async () => {
          const id = button.getAttribute("data-copy-template")
          const code = document.getElementById(`code-${id}`)
          if (!code) return

          const text = code.textContent || ""
          try {
            await navigator.clipboard.writeText(text)
            const original = button.textContent
            button.textContent = "Copied"
            setTimeout(() => {
              button.textContent = original
            }, 1200)
          } catch (_error) {
            // no-op
          }
        })
      })

      // Dialogs (includes alert dialogs)
      qs(document, "[data-slot='dialog']").forEach((root) => {
        const overlay = root.querySelector("[data-dialog-overlay]")
        const content = root.querySelector("[data-dialog-content]")

        const sync = (open) => {
          root.dataset.state = open ? "open" : "closed"
          toggleVisibility(overlay, open)
          toggleVisibility(content, open)
        }

        root.addEventListener("click", (event) => {
          if (event.target.closest("[data-dialog-trigger]")) sync(true)
          if (event.target.closest("[data-dialog-close]") || event.target.closest("[data-dialog-overlay]")) sync(false)
        })

        sync(root.dataset.state === "open")
      })

      // Drawers / sheets
      qs(document, "[data-slot='drawer']").forEach((root) => {
        const overlay = root.querySelector("[data-drawer-overlay]")
        const content = root.querySelector("[data-drawer-content]")

        const sync = (open) => {
          root.dataset.state = open ? "open" : "closed"
          toggleVisibility(overlay, open)
          toggleVisibility(content, open)
        }

        root.addEventListener("click", (event) => {
          if (event.target.closest("[data-drawer-trigger]")) sync(true)
          if (event.target.closest("[data-drawer-overlay]")) sync(false)
        })

        sync(root.dataset.state === "open")
      })

      // Popovers
      qs(document, "[data-slot='popover']").forEach((root) => {
        const trigger = root.querySelector("[data-popover-trigger]")
        const content = root.querySelector("[data-popover-content]")
        let open = false

        trigger?.addEventListener("click", (event) => {
          event.preventDefault()
          open = !open
          toggleVisibility(content, open)
        })

        document.addEventListener("click", (event) => {
          if (!root.contains(event.target)) {
            open = false
            toggleVisibility(content, false)
          }
        })
      })

      // Dropdown menus
      qs(document, "[data-slot='dropdown-menu']").forEach((root) => {
        const trigger = root.querySelector("[data-dropdown-trigger]")
        const content = root.querySelector("[data-dropdown-content]")
        let open = false

        trigger?.addEventListener("click", (event) => {
          event.preventDefault()
          open = !open
          toggleVisibility(content, open)
        })

        document.addEventListener("click", (event) => {
          if (!root.contains(event.target)) {
            open = false
            toggleVisibility(content, false)
          }
        })
      })

      // Combobox previews
      qs(document, "[data-slot='combobox']").forEach((root) => {
        const input = root.querySelector("[data-combobox-input]")
        const content = root.querySelector("[data-combobox-content]")
        const items = qs(root, "[data-slot='combobox-item']")

        input?.addEventListener("focus", () => toggleVisibility(content, true))
        input?.addEventListener("input", () => {
          const value = (input.value || "").toLowerCase()
          items.forEach((item) => {
            const text = (item.textContent || "").toLowerCase()
            item.classList.toggle("hidden", !text.includes(value))
          })
          toggleVisibility(content, true)
        })

        items.forEach((item) => {
          item.addEventListener("click", () => {
            input.value = item.getAttribute("data-value") || (item.textContent || "").trim()
            toggleVisibility(content, false)
          })
        })

        document.addEventListener("click", (event) => {
          if (!root.contains(event.target)) {
            toggleVisibility(content, false)
          }
        })
      })

      // Carousel previews
      qs(document, "[data-slot='carousel']").forEach((root) => {
        const track = root.querySelector("[data-carousel-track]")
        const items = qs(root, "[data-slot='carousel-item']")
        const prev = root.querySelector("[data-carousel-prev]")
        const next = root.querySelector("[data-carousel-next]")
        let index = 0

        const sync = () => {
          if (!track || items.length === 0) return
          track.style.transform = `translateX(-${index * 100}%)`
          track.style.transition = "transform 240ms ease"
        }

        prev?.addEventListener("click", () => {
          index = index === 0 ? items.length - 1 : index - 1
          sync()
        })

        next?.addEventListener("click", () => {
          index = index === items.length - 1 ? 0 : index + 1
          sync()
        })

        sync()
      })
    })()
    """
  end

  defp site_css do
    """
    html {
      scroll-behavior: smooth;
    }

    html.dark {
      color-scheme: dark;
    }

    .theme-mode-btn[data-active="true"] {
      background: var(--accent);
      color: var(--accent-foreground);
      border-color: var(--border);
    }

    .sidebar-link[aria-current="page"] {
      box-shadow: inset 2px 0 0 var(--ring);
    }

    .sidebar-section-link {
      color: var(--foreground);
    }

    .sidebar-section-link:hover {
      color: var(--foreground);
      text-decoration: underline;
      text-underline-offset: 0.2em;
    }

    summary::-webkit-details-marker {
      display: none;
    }

    summary::marker {
      content: "";
    }

    summary:not([data-slot])::after {
      content: "▾";
      float: right;
      color: var(--muted-foreground);
    }

    details[open] > summary:not([data-slot])::after {
      content: "▴";
    }

    .inline-code {
      border: 1px solid color-mix(in oklab, var(--border) 70%, transparent);
      border-radius: 0.35rem;
      background: color-mix(in oklab, var(--muted) 30%, transparent);
      color: var(--foreground);
      padding: 0.1rem 0.3rem;
      font-size: 0.9em;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
    }

    .docs-markdown {
      color: var(--muted-foreground);
      line-height: 1.7;
    }

    .docs-markdown > * + * {
      margin-top: 0.9rem;
    }

    .docs-markdown h1,
    .docs-markdown h2,
    .docs-markdown h3,
    .docs-markdown h4 {
      color: var(--foreground);
      font-weight: 600;
      line-height: 1.3;
      margin-top: 1.4rem;
    }

    .docs-markdown h1 {
      font-size: 1.35rem;
    }

    .docs-markdown h2 {
      font-size: 1.2rem;
    }

    .docs-markdown h3 {
      font-size: 1.05rem;
    }

    .docs-markdown ul,
    .docs-markdown ol {
      margin-left: 1.25rem;
    }

    .docs-markdown ul {
      list-style: disc;
    }

    .docs-markdown ol {
      list-style: decimal;
    }

    .docs-markdown li + li {
      margin-top: 0.3rem;
    }

    .docs-markdown a {
      color: var(--foreground);
      text-decoration: underline;
      text-underline-offset: 0.2em;
    }

    .docs-markdown pre {
      overflow: auto;
      border: 1px solid color-mix(in oklab, var(--border) 70%, transparent);
      border-radius: 0.5rem;
      background: color-mix(in oklab, var(--muted) 40%, transparent);
      padding: 0.75rem;
      line-height: 1.45;
    }

    .docs-markdown code {
      border: 1px solid color-mix(in oklab, var(--border) 75%, transparent);
      border-radius: 0.35rem;
      background: color-mix(in oklab, var(--muted) 30%, transparent);
      color: var(--foreground);
      padding: 0.1rem 0.3rem;
      font-size: 0.9em;
    }

    .docs-markdown pre code {
      border: 0;
      background: transparent;
      padding: 0;
      font-size: 0.95em;
    }

    .code-highlight {
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      line-height: 1.5;
    }

    .code-highlight .tok-tag {
      color: color-mix(in oklab, var(--primary) 75%, var(--foreground));
    }

    .code-highlight .tok-attr {
      color: color-mix(in oklab, var(--chart-2) 75%, var(--foreground));
    }

    .code-highlight .tok-string {
      color: color-mix(in oklab, var(--chart-4) 85%, var(--foreground));
    }

    .code-highlight .tok-expr {
      color: color-mix(in oklab, var(--chart-5) 85%, var(--foreground));
    }

    .code-highlight .tok-keyword {
      color: color-mix(in oklab, var(--chart-1) 80%, var(--foreground));
    }

    .code-highlight .tok-comment {
      color: var(--muted-foreground);
      font-style: italic;
    }
    """
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
