defmodule Demo.SiteRenderer do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Docs.UIComponents
  alias CinderUI.Site.Marketing
  alias Demo.SiteRuntime
  alias Phoenix.HTML.Safe

  def marketing_html do
    Marketing.render_marketing_html(%{
      component_count: SiteRuntime.catalog_component_count(),
      docs_path: "/docs/",
      theme_css_path: "/assets/theme.css",
      site_css_path: "/assets/site.css"
    })
  end

  def docs_index_html do
    sections = SiteRuntime.catalog_sections()

    page_shell(
      title: "Cinder UI Docs",
      description: "Component docs for Cinder UI",
      body_content: docs_index_body(sections),
      sections: sections,
      active_entry_id: nil,
      root_prefix: "/docs",
      home_url: "/"
    )
  end

  def docs_component_html(entry) do
    sections = SiteRuntime.catalog_sections()

    page_shell(
      title: "#{entry.module_name}.#{entry.title} · Cinder UI",
      description: entry.docs,
      body_content: docs_component_body(entry, sections),
      sections: sections,
      active_entry_id: entry.id,
      root_prefix: "/docs",
      home_url: "/"
    )
  end

  defp page_shell(opts) do
    assigns = %{
      title: opts[:title],
      description: opts[:description],
      body_content: opts[:body_content],
      sections: opts[:sections],
      active_entry_id: opts[:active_entry_id],
      root_prefix: opts[:root_prefix],
      home_url: opts[:home_url]
    }

    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title}</title>
        <meta name="description" content={@description} />
        <link rel="stylesheet" href="/assets/theme.css" />
        <link rel="stylesheet" href="/assets/site.css" />
      </head>
      <body class="bg-background text-foreground">
        <UIComponents.docs_layout
          sections={@sections}
          mode={:static}
          root_prefix={@root_prefix}
          active_entry_id={@active_entry_id}
          home_url={@home_url}
          github_url={project_source_url()}
          hex_package_url="https://hex.pm/packages/cinder_ui"
        >
          {rendered(@body_content)}
        </UIComponents.docs_layout>

        <script src="/assets/site.js">
        </script>
      </body>
    </html>
    """
    |> to_html()
  end

  defp docs_index_body(sections) do
    assigns = %{sections: sections, component_count: SiteRuntime.catalog_component_count()}

    ~H"""
    <UIComponents.docs_overview_intro component_count={@component_count} show_count={true} />

    <UIComponents.docs_overview_sections sections={@sections} mode={:static} root_prefix="/docs" />
    """
    |> to_html()
  end

  defp docs_component_body(entry, sections) do
    assigns = %{entry: entry, sections: sections}

    ~H"""
    <UIComponents.docs_component_detail
      entry={@entry}
      sections={@sections}
      mode={:static}
      root_prefix="/docs"
    />
    """
    |> to_html()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp project_source_url do
    Mix.Project.config()[:source_url]
    |> to_string()
  end
end
