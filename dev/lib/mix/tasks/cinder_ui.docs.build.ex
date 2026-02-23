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
  use Phoenix.Component

  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Actions
  alias CinderUI.Components.Navigation
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
    page_shell(
      title: "Cinder UI Docs",
      description: "Static component docs for Cinder UI",
      body_content: overview_body_html(sections),
      theme_css: theme_css,
      asset_prefix: ".",
      sidebar: sidebar_links(sections, ".", nil),
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp component_page_html(entry, sections, theme_css, home_url, github_url, hex_package_url) do
    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: component_body_html(entry, sections),
      theme_css: theme_css,
      asset_prefix: "..",
      sidebar: sidebar_links(sections, "..", entry.id),
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp page_shell(opts) do
    assigns = %{
      title: opts[:title],
      description: opts[:description],
      body_content: opts[:body_content],
      theme_css: opts[:theme_css],
      asset_prefix: opts[:asset_prefix],
      sidebar: opts[:sidebar],
      home_url: opts[:home_url],
      github_url: opts[:github_url],
      hex_package_url: opts[:hex_package_url]
    }

    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title}</title>
        <meta name="description" content={@description} />
        <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4">
        </script>
        <style type="text/tailwindcss">
          <%= Phoenix.HTML.raw(@theme_css) %>

          @layer base {
            body {
              @apply min-h-screen;
            }
          }
        </style>
        <link rel="stylesheet" href={"#{@asset_prefix}/assets/site.css"} />
      </head>
      <body class="bg-background text-foreground">
        <div class="mx-auto grid min-h-screen max-w-[1900px] grid-cols-1 lg:grid-cols-[320px_minmax(0,1fr)]">
          <aside class="border-border/70 sticky top-0 h-screen overflow-y-auto border-r px-5 py-6">
            <div class="mb-6">
              <h1 class="text-xl font-semibold">Cinder UI</h1>
              <p class="text-muted-foreground mt-1 text-sm">Static component docs</p>
              {Phoenix.HTML.raw(header_links_html(@home_url, @github_url, @hex_package_url))}
            </div>

            {Phoenix.HTML.raw(theme_controls_html())}

            <nav class="space-y-4" aria-label="Component sections">
              {Phoenix.HTML.raw(@sidebar)}
            </nav>

            <div class="mt-6 text-xs text-muted-foreground">
              Generated by <code>mix cinder_ui.docs.build</code>
            </div>
          </aside>

          <main class="min-w-0 px-5 py-6 lg:px-8">
            {Phoenix.HTML.raw(@body_content)}
          </main>
        </div>

        <script src={"#{@asset_prefix}/assets/site.js"}>
        </script>
      </body>
    </html>
    """
    |> to_html()
  end

  defp overview_body_html(sections) do
    assigns = %{sections: sections}

    ~H"""
    <section class="mb-8">
      <h2 class="text-2xl font-semibold tracking-tight">Component Library</h2>
      <p class="text-muted-foreground mt-2 max-w-3xl text-sm">
        Static docs for Cinder UI components. Open any component for preview, HEEx usage,
        generated attributes/slots docs, and a link to the original shadcn/ui reference.
      </p>
    </section>

    {Phoenix.HTML.raw(overview_sections_html(@sections))}
    """
    |> to_html()
  end

  defp component_body_html(entry, sections) do
    examples_html = component_examples_html(entry)
    docs_html = inline_code_html(entry.docs)
    attrs_html = attributes_table_html(entry.attributes)
    slots_html = slots_table_html(entry.slots)
    function_docs_html = function_docs_panel_html(entry.docs_full, entry.docs)
    back_section_id = section_id_for_entry(sections, entry.id)

    assigns = %{
      entry: entry,
      examples_html: examples_html,
      docs_html: docs_html,
      attrs_html: attrs_html,
      slots_html: slots_html,
      function_docs_html: function_docs_html,
      back_section_id: back_section_id
    }

    ~H"""
    <div class="mb-6 flex flex-wrap items-center justify-between gap-3">
      <Actions.button
        as="a"
        href={"../index.html##{@back_section_id}"}
        variant={:outline}
        size={:xs}
      >
        ← Back to index
      </Actions.button>
      <Actions.button
        as="a"
        href={@entry.shadcn_url}
        target="_blank"
        rel="noopener noreferrer"
        variant={:outline}
        size={:xs}
      >
        Original shadcn/ui docs ↗
      </Actions.button>
    </div>

    <section class="mb-6">
      <p class="text-muted-foreground text-xs">{@entry.module_name}</p>
      <h2 class="mt-1 text-2xl font-semibold tracking-tight">
        <code>{@entry.module_name}.{@entry.title}</code>
      </h2>
      <p class="text-muted-foreground mt-3 text-sm">{Phoenix.HTML.raw(@docs_html)}</p>
    </section>

    <section class="mb-8 space-y-4">{Phoenix.HTML.raw(@examples_html)}</section>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Attributes</h3>
      {Phoenix.HTML.raw(@attrs_html)}
    </section>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Slots</h3>
      {Phoenix.HTML.raw(@slots_html)}
    </section>

    {Phoenix.HTML.raw(@function_docs_html)}
    """
    |> to_html()
  end

  defp sidebar_links(sections, root_prefix, active_entry_id) do
    assigns = %{
      sections: sections,
      root_prefix: root_prefix,
      active_entry_id: active_entry_id,
      index_href: "#{root_prefix}/index.html",
      overview_active?: is_nil(active_entry_id)
    }

    ~H"""
    <div>
      <a
        href={@index_href}
        class={sidebar_link_class(@overview_active?)}
        aria-current={if @overview_active?, do: "page", else: nil}
      >
        Overview
      </a>
    </div>

    <%= for section <- @sections do %>
      <div>
        <a href={"#{@index_href}##{section.id}"} class="sidebar-section-link text-sm font-semibold">
          {section.title}
        </a>
        <ul class="mt-2 space-y-1">
          <li :for={entry <- section.entries}>
            <a
              class={sidebar_link_class(entry.id == @active_entry_id)}
              href={"#{@root_prefix}/#{entry.docs_path}"}
              aria-current={if entry.id == @active_entry_id, do: "page", else: nil}
            >
              {entry.title}
            </a>
          </li>
        </ul>
      </div>
    <% end %>
    """
    |> to_html()
  end

  defp header_links_html(home_url, github_url, hex_package_url) do
    assigns = %{
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    }

    ~H"""
    <div
      :if={
        (is_binary(@home_url) and @home_url != "") or
          (is_binary(@github_url) and @github_url != "") or
          (is_binary(@hex_package_url) and @hex_package_url != "")
      }
      class="mt-3 flex flex-wrap gap-1 text-xs"
    >
      <Actions.button
        :if={is_binary(@home_url) and @home_url != ""}
        as="a"
        href={@home_url}
        variant={:outline}
        size={:xs}
      >
        Home
      </Actions.button>
      <Actions.button
        :if={is_binary(@github_url) and @github_url != ""}
        as="a"
        href={@github_url}
        target="_blank"
        rel="noopener noreferrer"
        variant={:outline}
        size={:xs}
      >
        GitHub
      </Actions.button>
      <Actions.button
        :if={is_binary(@hex_package_url) and @hex_package_url != ""}
        as="a"
        href={@hex_package_url}
        target="_blank"
        rel="noopener noreferrer"
        variant={:outline}
        size={:xs}
      >
        Hex package
      </Actions.button>
    </div>
    """
    |> to_html()
  end

  defp theme_controls_html do
    assigns = %{
      color_options: select_options(["gray", "neutral", "slate", "stone", "zinc"]),
      radius_options:
        select_entries([
          {"maia", "Compact (6px / 0.375rem)"},
          {"mira", "Small (8px / 0.5rem)"},
          {"nova", "Default (12px / 0.75rem)"},
          {"lyra", "Large (14px / 0.875rem)"},
          {"vega", "XL (16px / 1rem)"}
        ])
    }

    ~H"""
    <section class="mb-6 rounded-lg border p-3">
      <h2 class="text-sm font-semibold">Theme</h2>

      <div class="mt-3">
        <p class="mb-2 text-xs font-medium text-muted-foreground">Mode</p>
        <Navigation.tabs value="auto" class="w-full gap-0 [&_[data-slot=tabs-list]]:w-full">
          <:trigger value="light" data_theme_mode="light" class="theme-mode-btn">Light</:trigger>
          <:trigger value="dark" data_theme_mode="dark" class="theme-mode-btn">Dark</:trigger>
          <:trigger value="auto" data_theme_mode="auto" class="theme-mode-btn">Auto</:trigger>
        </Navigation.tabs>
      </div>

      <div class="mt-3">
        <label for="theme-color" class="mb-1 block text-xs font-medium text-muted-foreground">
          Base color
        </label>
        <p class="mb-2 text-[11px] text-muted-foreground">
          Matches shadcn <code>tailwind.baseColor</code>.
        </p>
        <Forms.select
          name="theme-color"
          value="neutral"
          id="theme-color"
          aria-label="Theme color"
        >
          <:option :for={option <- @color_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>

      <div class="mt-3">
        <label for="theme-radius" class="mb-2 block text-xs font-medium text-muted-foreground">
          Radius
        </label>
        <Forms.select
          name="theme-radius"
          value="nova"
          id="theme-radius"
          aria-label="Theme radius"
        >
          <:option :for={option <- @radius_options} value={option.value} label={option.label} />
        </Forms.select>
      </div>
    </section>
    """
    |> to_html()
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
    assigns = %{sections: sections}

    ~H"""
    <%= for section <- @sections do %>
      <section id={section.id} class="mb-12">
        <h3 class="mb-4 text-xl font-semibold">{section.title}</h3>
        <div class="grid gap-4 md:grid-cols-2">
          <%= for entry <- section.entries do %>
            {Phoenix.HTML.raw(overview_entry_html(entry))}
          <% end %>
        </div>
      </section>
    <% end %>
    """
    |> to_html()
  end

  defp overview_entry_html(entry) do
    assigns = %{
      entry: entry,
      docs_html: inline_code_html(entry.docs),
      template_html: escape(entry.template_heex),
      attrs_count: length(entry.attributes),
      slots_count: length(entry.slots),
      preview_align: entry.preview_align || :center
    }

    ~H"""
    <article
      id={@entry.id}
      data-component-card
      data-component-name={@entry.title}
      class="flex h-full flex-col rounded-xl border bg-card text-card-foreground shadow-sm"
    >
      <header class="border-border/70 border-b px-4 py-3">
        <div class="flex flex-wrap items-start justify-between gap-2">
          <h4 class="font-medium">
            <a href={"./#{@entry.docs_path}"} class="hover:underline underline-offset-4">
              <code>{@entry.module_name}.{@entry.title}</code>
            </a>
          </h4>
          <div class="flex items-center gap-1">
            <Actions.button
              as="a"
              href={"./#{@entry.docs_path}"}
              variant={:outline}
              size={:xs}
            >
              Open docs
            </Actions.button>
          </div>
        </div>
        <p class="text-muted-foreground mt-2 text-sm">{Phoenix.HTML.raw(@docs_html)}</p>
      </header>

      <div
        class={[
          "bg-background border-border/70 flex min-h-[7rem] flex-1 p-4",
          @preview_align == :center && "items-center justify-center"
        ]}
        data-preview-align={@preview_align}
      >
        <div class={["w-full", @preview_align == :center && "flex justify-center"]}>
          {Phoenix.HTML.raw(@entry.preview_html)}
        </div>
      </div>
      <div class="relative min-w-0 border-t border-b border-border/70 bg-muted/30">
        <button
          type="button"
          data-copy-template={@entry.id}
          aria-label="Copy HEEx"
          title="Copy HEEx"
          class="absolute top-2.5 right-2 z-10 inline-flex h-7 w-7 items-center justify-center rounded-md border bg-background/80 text-xs hover:bg-accent hover:text-accent-foreground"
        >
          <Icons.icon name="copy" class="size-3.5" />
        </button>
        <pre class="min-w-0 max-w-full max-h-56 overflow-x-auto overflow-y-auto p-4 pr-12 text-xs">
          <code id={"code-#{@entry.id}"} class="block min-w-max whitespace-pre"><%= Phoenix.HTML.raw(@template_html) %></code>
        </pre>
      </div>
      <div class="flex flex-wrap items-center justify-between gap-2 p-4 text-xs">
        <span class="text-muted-foreground">
          attrs: <span class="font-medium text-foreground">{@attrs_count}</span>
          · slots: <span class="font-medium text-foreground">{@slots_count}</span>
        </span>
        <a
          href={@entry.shadcn_url}
          target="_blank"
          rel="noopener noreferrer"
          class="text-muted-foreground hover:text-foreground underline underline-offset-4"
        >
          shadcn reference ↗
        </a>
      </div>
    </article>
    """
    |> to_html()
  end

  defp component_examples_html(entry) do
    assigns = %{
      entry: entry,
      total: length(entry.examples)
    }

    ~H"""
    <%= for {example, index} <- Enum.with_index(@entry.examples, 1) do %>
      <section class="mb-10">
        <header>
          <h3 class="text-sm font-semibold">{example_heading(example.title, index, @total)}</h3>
          <p
            :if={is_binary(example.description) and example.description != ""}
            class="text-muted-foreground mt-1 text-xs"
          >
            {example.description}
          </p>
        </header>

        <div data-slot="component-preview" class="mt-4 overflow-hidden rounded-xl border">
          <div
            data-slot="preview"
            data-preview-align={example.preview_align || :center}
            class={[
              "p-4 sm:p-6",
              (example.preview_align || :center) == :center &&
                "flex items-center justify-center"
            ]}
          >
            {Phoenix.HTML.raw(example.preview_html)}
          </div>

          <div data-slot="code" class="relative min-w-0 border-t bg-muted/20">
            <button
              type="button"
              data-copy-template={"#{@entry.id}-#{example.id}"}
              aria-label="Copy HEEx"
              title="Copy HEEx"
              class="absolute top-2.5 right-2 z-10 inline-flex h-7 w-7 items-center justify-center rounded-md border bg-background/80 text-xs hover:bg-accent hover:text-accent-foreground"
            >
              <Icons.icon name="copy" class="size-3.5" />
            </button>
            <pre class="min-w-0 max-h-96 w-full max-w-full overflow-x-auto overflow-y-auto bg-muted/30 p-4 text-xs">
              <code
                id={"code-#{@entry.id}-#{example.id}"}
                class="block min-w-max whitespace-pre"
              >{example.template_heex}</code>
            </pre>
          </div>
        </div>
      </section>
    <% end %>
    """
    |> to_html()
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
      assigns = %{docs_html: docs_full_html(residual)}

      ~H"""
      <section class="mb-6">
        <h3 class="mb-3 text-sm font-semibold">Function Docs</h3>
        <div class="space-y-3 text-sm">{Phoenix.HTML.raw(@docs_html)}</div>
      </section>
      """
      |> to_html()
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
    assigns = %{}

    ~H"""
    <p class="text-sm text-muted-foreground">No attributes declared.</p>
    """
    |> to_html()
  end

  defp attributes_table_html(attrs) do
    assigns = %{attrs: attrs}

    ~H"""
    <div class="overflow-auto rounded-md border">
      <table class="w-full min-w-[680px] text-left text-xs">
        <thead class="bg-muted/40">
          <tr>
            <th class="px-3 py-2 font-medium">Name</th>
            <th class="px-3 py-2 font-medium">Type</th>
            <th class="px-3 py-2 font-medium">Default</th>
            <th class="px-3 py-2 font-medium">Values</th>
            <th class="px-3 py-2 font-medium">Global Includes</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={attr <- @attrs} class="border-border/60 border-t align-top">
            <td class="px-3 py-2">
              <code>{attr.name}</code>
              <%= if attr.required do %>
                {Phoenix.HTML.raw(required_badge_html("ml-2"))}
              <% end %>
            </td>
            <td class="px-3 py-2"><code>{attr.type}</code></td>
            <td class="px-3 py-2">
              <%= if is_nil(attr.default) do %>
                —
              <% else %>
                <code>{inspect(attr.default)}</code>
              <% end %>
            </td>
            <td class="px-3 py-2">
              <%= if attr.values == [] do %>
                —
              <% else %>
                <%= for {value, idx} <- Enum.with_index(attr.values) do %>
                  <%= if idx > 0 do %>
                    ,
                  <% end %>
                  <code>{inspect(value)}</code>
                <% end %>
              <% end %>
            </td>
            <td class="px-3 py-2">
              <%= if attr.includes == [] do %>
                —
              <% else %>
                <%= for {include, idx} <- Enum.with_index(attr.includes) do %>
                  <%= if idx > 0 do %>
                    ,
                  <% end %>
                  <code>{include}</code>
                <% end %>
              <% end %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
    |> to_html()
  end

  defp slots_table_html([]) do
    assigns = %{}

    ~H"""
    <p class="text-sm text-muted-foreground">No slots declared.</p>
    """
    |> to_html()
  end

  defp slots_table_html(slots) do
    assigns = %{slots: slots}

    ~H"""
    <div class="overflow-auto rounded-md border">
      <table class="w-full min-w-[560px] text-left text-xs">
        <thead class="bg-muted/40">
          <tr>
            <th class="px-3 py-2 font-medium">Slot</th>
            <th class="px-3 py-2 font-medium">Slot Attributes</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={slot <- @slots} class="border-border/60 border-t align-top">
            <td class="px-3 py-2">
              <code>{slot.name}</code>
              <%= if slot.required do %>
                {Phoenix.HTML.raw(required_badge_html("ml-2"))}
              <% end %>
            </td>
            <td class="px-3 py-2">{Phoenix.HTML.raw(slot_attrs_summary(slot.attrs))}</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
    |> to_html()
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
    assigns = %{extra_class: extra_class}

    ~H"""
    <Feedback.badge variant={:destructive} class={"align-middle #{@extra_class}"}>
      Required
    </Feedback.badge>
    """
    |> to_html()
  end

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  defp site_js, do: docs_asset!("site.js")
  defp site_css, do: docs_asset!("site.css")

  defp docs_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "docs", name])
    |> File.read!()
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
