defmodule Mix.Tasks.CinderUi.Docs.Build do
  @shortdoc "Builds the unified static Cinder UI site (marketing + docs)"
  @moduledoc """
  Builds a unified static Cinder UI site.

  The generated output includes:

  - `index.html` marketing/developer landing page
  - static component docs under `docs/`

  Output can be deployed to any static host (GitHub Pages, Netlify, S3, etc)
  without running Phoenix/Elixir on the server.

  ## Examples

      mix cinder_ui.docs.build
  """

  use Mix.Task
  use Phoenix.Component

  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Actions
  alias CinderUI.Docs.Catalog
  alias CinderUI.Docs.UIComponents
  alias CinderUI.Site.Marketing
  alias CinderUI.Icons
  alias Phoenix.HTML
  alias Phoenix.HTML.Safe

  @impl true
  def run(argv) do
    if argv != [] do
      Mix.raise("`mix cinder_ui.docs.build` does not accept flags or options.")
    end

    output_dir = Path.expand("dist/site", File.cwd!())
    project = Mix.Project.config()
    github_url = to_string(project[:source_url] || "")
    hex_package_url = "https://hex.pm/packages/cinder_ui"
    hexdocs_url = "https://hexdocs.pm/cinder_ui"
    docs_output_dir = Path.join(output_dir, "docs")
    home_url = "../index.html"

    if File.dir?(output_dir), do: File.rm_rf!(output_dir)

    assets_dir = Path.join(docs_output_dir, "assets")
    File.mkdir_p!(assets_dir)
    build_theme_css!(assets_dir)

    sections = Catalog.sections()
    entries = Enum.flat_map(sections, & &1.entries)

    File.write!(
      Path.join(docs_output_dir, "index.html"),
      overview_page_html(sections, home_url, github_url, hex_package_url)
    )

    Enum.each(entries, fn entry ->
      output_path = Path.join(docs_output_dir, entry.docs_path)
      File.mkdir_p!(Path.dirname(output_path))

      File.write!(
        output_path,
        component_page_html(entry, sections, home_url, github_url, hex_package_url)
      )
    end)

    File.write!(Path.join(assets_dir, "site.js"), site_js())
    File.write!(Path.join(assets_dir, "site.css"), site_css())

    Marketing.write_marketing_index!(output_dir, %{
      github_url: github_url,
      hex_url: hex_package_url,
      hexdocs_url: hexdocs_url,
      component_count: length(entries),
      docs_path: "./docs/index.html",
      theme_css_path: "./docs/assets/theme.css",
      site_css_path: "./docs/assets/site.css"
    })

    Mix.shell().info("generated #{relative(output_dir)}")
    Mix.shell().info("entries: #{Catalog.entry_count()}")
    Mix.shell().info("open #{relative(Path.join(output_dir, "index.html"))} in a browser")
    Mix.shell().info("open #{relative(Path.join(docs_output_dir, "index.html"))} for docs index")
  end

  defp overview_page_html(sections, home_url, github_url, hex_package_url) do
    page_shell(
      title: "Cinder UI Docs",
      description: "Static component docs for Cinder UI",
      body_content: overview_body_html(sections),
      asset_prefix: ".",
      sections: sections,
      root_prefix: ".",
      active_entry_id: nil,
      show_overview: true,
      home_url: home_url,
      github_url: github_url,
      hex_package_url: hex_package_url
    )
  end

  defp component_page_html(entry, sections, home_url, github_url, hex_package_url) do
    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: component_body_html(entry, sections),
      asset_prefix: "..",
      sections: sections,
      root_prefix: "..",
      active_entry_id: entry.id,
      show_overview: true,
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
      asset_prefix: opts[:asset_prefix],
      sections: opts[:sections],
      root_prefix: opts[:root_prefix],
      active_entry_id: opts[:active_entry_id],
      show_overview: opts[:show_overview],
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
        <link rel="stylesheet" href={"#{@asset_prefix}/assets/theme.css"} />
        <link rel="stylesheet" href={"#{@asset_prefix}/assets/site.css"} />
      </head>
      <body class="bg-background text-foreground">
        <UIComponents.docs_layout
          sections={@sections}
          mode={:static}
          root_prefix={@root_prefix}
          active_entry_id={@active_entry_id}
          show_overview={@show_overview}
          home_url={@home_url}
          github_url={@github_url}
          hex_package_url={@hex_package_url}
        >
          {rendered(@body_content)}
        </UIComponents.docs_layout>

        <script src={"#{@asset_prefix}/assets/site.js"}>
        </script>
        {rendered(docs_speculation_rules_html())}
      </body>
    </html>
    """
    |> to_html()
  end

  defp overview_body_html(sections) do
    assigns = %{sections: sections}

    ~H"""
    <UIComponents.docs_overview_intro />

    <UIComponents.docs_overview_sections sections={@sections} mode={:static} root_prefix="." />
    """
    |> to_html()
  end

  defp component_body_html(entry, sections) do
    examples_html = component_examples_html(entry)
    docs_html = summary_markdown_html(entry.docs)
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
      <div class="docs-markdown mt-3 text-sm">{rendered(@docs_html)}</div>
    </section>

    {rendered(@function_docs_html)}

    <section class="mb-8 space-y-4">{rendered(@examples_html)}</section>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Attributes</h3>
      {rendered(@attrs_html)}
    </section>

    <section class="mb-6">
      <h3 class="mb-3 text-sm font-semibold">Slots</h3>
      {rendered(@slots_html)}
    </section>
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
            {rendered(example.preview_html)}
          </div>

          <div data-slot="code" class="relative min-w-0 border-t bg-muted/20">
            <button
              type="button"
              data-copy-template={"#{@entry.id}-#{example.id}"}
              aria-label="Copy HEEx"
              title="Copy HEEx"
              class="absolute top-2.5 right-2 z-10 inline-flex h-7 w-7 items-center justify-center rounded-md border bg-background/80 text-xs hover:bg-accent hover:text-accent-foreground"
            >
              <Icons.icon name="copy" class="size-4" />
            </button>
            <pre class="m-0 min-w-0 max-h-96 w-full max-w-full overflow-x-auto overflow-y-auto bg-muted/30 p-4 text-xs leading-4"><code id={"code-#{@entry.id}-#{example.id}"} class="block min-w-max whitespace-pre">{example.template_heex}</code></pre>
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

  defp summary_markdown_html(text) do
    case Earmark.as_html(text, compact_output: true) do
      {:ok, html, _messages} -> sanitize_docs_html(html)
      {:error, html, _messages} -> sanitize_docs_html(html)
    end
  rescue
    _ ->
      "<p>#{escape(text)}</p>"
  end

  defp function_docs_panel_html(docs_full, summary) do
    residual = docs_residual(docs_full, summary)

    if residual == "" do
      ""
    else
      assigns = %{docs_html: docs_full_html(residual)}

      ~H"""
      <section class="mb-6">
        <div class="space-y-3 text-sm">{rendered(@docs_html)}</div>
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
      ~w(example examples attribute attributes slot slots usage variant variants screenshot screenshots)
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
                {rendered(required_badge_html("ml-2"))}
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
                {rendered(required_badge_html("ml-2"))}
              <% end %>
            </td>
            <td class="px-3 py-2">{rendered(slot_attrs_summary(slot.attrs))}</td>
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

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()

  defp site_js do
    [site_asset!("shared.js"), docs_asset!("site.js")]
    |> Enum.join(";\n\n")
    |> Kernel.<>(";\n")
  end

  defp site_css do
    site_asset!("site.css")
  end

  defp build_theme_css!(assets_dir) do
    docs_assets_dir = Path.join([File.cwd!(), "dev", "assets", "docs"])
    ensure_npm_available!()
    ensure_docs_tailwind_deps!(docs_assets_dir)

    output_path = Path.join(assets_dir, "theme.css")
    node_modules_path = Path.join(docs_assets_dir, "node_modules")

    run_cmd!("npm", ["exec", "--", "tailwindcss", "--input=theme.css", "--output=#{output_path}"],
      cd: docs_assets_dir,
      env: [{"NODE_PATH", node_modules_path}]
    )
  end

  defp ensure_npm_available! do
    cond do
      is_nil(System.find_executable("node")) ->
        Mix.raise("node is required to build docs CSS. Please install/activate Node.js.")

      is_nil(System.find_executable("npm")) ->
        Mix.raise("npm is required to build docs CSS. Please install/activate npm.")

      true ->
        :ok
    end
  end

  defp ensure_docs_tailwind_deps!(docs_assets_dir) do
    node_modules_dir = Path.join(docs_assets_dir, "node_modules")

    if File.dir?(node_modules_dir) do
      :ok
    else
      Mix.shell().info("installing docs CSS dependencies (dev/assets/docs)")

      run_cmd!("npm", ["install", "--no-audit", "--no-fund"], cd: docs_assets_dir)
    end
  end

  defp run_cmd!(command, args, opts) do
    {output, status} = System.cmd(command, args, Keyword.put(opts, :stderr_to_stdout, true))

    if status != 0 do
      Mix.raise("""
      command failed: #{command} #{Enum.join(args, " ")}
      #{output}
      """)
    end
  end

  defp docs_speculation_rules_html do
    template!("docs_speculation_rules.html.eex")
    |> EEx.eval_string([])
  end

  defp docs_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "docs", name])
    |> File.read!()
  end

  defp site_asset!(name) do
    Path.join([File.cwd!(), "dev", "assets", "site", name])
    |> File.read!()
  end

  defp template!(name) do
    Path.join([File.cwd!(), "priv", "site_templates", name])
    |> File.read!()
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
