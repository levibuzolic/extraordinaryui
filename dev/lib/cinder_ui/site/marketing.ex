defmodule CinderUI.Site.Marketing do
  @moduledoc false

  use Phoenix.Component

  alias CinderUI.Components.Actions
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Docs.UIComponents, as: Docs
  alias CinderUI.Icons
  alias Phoenix.HTML.Safe

  @template_dir Path.expand("../../../../priv/site_templates", __DIR__)

  def write_marketing_index!(output_dir, opts \\ %{}) do
    project = Mix.Project.config()
    github_url = Map.get(opts, :github_url, to_string(project[:source_url] || ""))
    hex_url = Map.get(opts, :hex_url, "https://hex.pm/packages/cinder_ui")
    hexdocs_url = Map.get(opts, :hexdocs_url, "https://hexdocs.pm/cinder_ui")
    version = Map.get(opts, :version, to_string(project[:version] || "0.0.0"))
    component_count = Map.get(opts, :component_count, 0)
    docs_path = Map.get(opts, :docs_path, "./docs/")
    theme_css_path = Map.get(opts, :theme_css_path, "./docs/assets/theme.css")
    site_css_path = Map.get(opts, :site_css_path, "./assets/site.css")

    theme_script_src =
      Map.get(opts, :theme_script_src, Path.join(docs_path, "assets/static_docs.js"))

    File.mkdir_p!(output_dir)

    File.write!(
      Path.join(output_dir, "index.html"),
      index_html(
        version,
        component_count,
        github_url,
        hex_url,
        hexdocs_url,
        theme_css_path,
        docs_path,
        site_css_path,
        theme_script_src
      )
    )

    File.write!(Path.join(output_dir, ".nojekyll"), "")
  end

  def render_marketing_html(opts \\ %{}) do
    project = Mix.Project.config()
    github_url = Map.get(opts, :github_url, to_string(project[:source_url] || ""))
    hex_url = Map.get(opts, :hex_url, "https://hex.pm/packages/cinder_ui")
    hexdocs_url = Map.get(opts, :hexdocs_url, "https://hexdocs.pm/cinder_ui")
    version = Map.get(opts, :version, to_string(project[:version] || "0.0.0"))
    component_count = Map.get(opts, :component_count, 0)
    docs_path = Map.get(opts, :docs_path, "./docs/")
    theme_css_path = Map.get(opts, :theme_css_path, "./docs/assets/theme.css")
    site_css_path = Map.get(opts, :site_css_path, "./assets/site.css")

    theme_script_src =
      Map.get(opts, :theme_script_src, Path.join(docs_path, "assets/static_docs.js"))

    index_html(
      version,
      component_count,
      github_url,
      hex_url,
      hexdocs_url,
      theme_css_path,
      docs_path,
      site_css_path,
      theme_script_src
    )
  end

  defp index_html(
         version,
         component_count,
         github_url,
         hex_url,
         hexdocs_url,
         theme_css_path,
         docs_path,
         site_css_path,
         theme_script_src
       ) do
    shadcn_url = "https://ui.shadcn.com/docs"

    assigns = [
      theme_bootstrap_script: theme_bootstrap_script(),
      theme_css_path: theme_css_path,
      site_css_path: site_css_path,
      header_controls_html:
        header_controls_html(docs_path, github_url, hex_url, hexdocs_url),
      shadcn_url: shadcn_url,
      hero_html: hero_html(version, component_count, shadcn_url, docs_path),
      component_examples_html: component_examples_html(shadcn_url),
      install_html: install_html(version, docs_path),
      features_html: features_html(shadcn_url),
      footer_html:
        footer_html(github_url, hex_url, hexdocs_url, shadcn_url, docs_path),
      theme_script_src: theme_script_src
    ]

    "index.html.eex"
    |> template!()
    |> EEx.eval_string(assigns)
  end

  defp header_controls_html(docs_path, github_url, hex_url, hexdocs_url) do
    assigns = %{
      docs_path: docs_path,
      github_url: github_url,
      hex_url: hex_url,
      hexdocs_url: hexdocs_url
    }

    ~H"""
    <div class="flex flex-wrap items-center gap-2 md:justify-end">
      <Docs.docs_external_link_button
        :if={is_binary(@github_url) and @github_url != ""}
        href={@github_url}
        variant={:outline}
        size={:sm}
      >
        GitHub
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hex_url) and @hex_url != ""}
        href={@hex_url}
        variant={:outline}
        size={:sm}
      >
        Hex
      </Docs.docs_external_link_button>
      <Docs.docs_external_link_button
        :if={is_binary(@hexdocs_url) and @hexdocs_url != ""}
        href={@hexdocs_url}
        variant={:outline}
        size={:sm}
      >
        HexDocs
      </Docs.docs_external_link_button>

      <Docs.theme_mode_toggle class="site-theme-toggle" />
    </div>
    """
    |> to_html()
  end

  defp hero_html(version, component_count, shadcn_url, docs_path) do
    assigns = %{
      version: version,
      component_count: component_count,
      shadcn_url: shadcn_url,
      docs_path: docs_path,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section class="bp-hero relative overflow-hidden">
      <div class="bp-dot-grid absolute inset-0 pointer-events-none" aria-hidden="true"></div>
      <div class="relative grid gap-8 lg:grid-cols-[1fr_auto] lg:gap-12 py-12 md:py-16">
        <div class="space-y-6">
          <div class="flex flex-wrap items-center gap-2">
            <Feedback.badge variant={:outline}>
              v{@version}
            </Feedback.badge>
            <Feedback.badge variant={:secondary}>
              {@component_count} components
            </Feedback.badge>
          </div>
          <h1 class="bp-heading text-4xl font-semibold tracking-tight sm:text-5xl lg:text-6xl">
            Components for Phoenix.
          </h1>
          <p class="max-w-xl text-base text-muted-foreground md:text-lg">
            <a
              href={@shadcn_url}
              target="_blank"
              rel="noopener noreferrer"
              class="underline underline-offset-4"
            >shadcn/ui</a>
            patterns, server-rendered. Typed HEEx APIs. One command to install.
          </p>
          <div class="flex flex-wrap gap-3">
            <Actions.button as="a" href={@docs_path}>
              Browse Components
            </Actions.button>
            <Actions.button as="a" variant={:outline} href="#install">
              Quick Start
            </Actions.button>
          </div>
        </div>

        <div class="bp-terminal lg:self-center lg:min-w-[360px]">
          <div class="bp-terminal-chrome">
            <span class="bp-terminal-dot"></span>
            <span class="bp-terminal-dot"></span>
            <span class="bp-terminal-dot"></span>
            <span class="bp-terminal-title">Terminal</span>
          </div>
          <div class="bp-terminal-body">
            <code class="bp-terminal-line">
              <span class="text-muted-foreground">$</span>
              <span> mix cinder_ui.install --skip-existing</span><span class="bp-cursor">|</span>
            </code>
          </div>
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp component_examples_html(shadcn_url) do
    assigns = %{
      cards: [
        button_group_example_card(shadcn_url),
        form_example_card(shadcn_url),
        alert_example_card(shadcn_url),
        tabs_example_card(shadcn_url)
      ]
    }

    ~H"""
    <section id="examples">
      <div class="bp-section-connector" aria-hidden="true"></div>
      <p class="bp-section-label">// components</p>
      <div class="grid gap-4 md:grid-cols-2 mt-4">
        <.marketing_example_card
          :for={card <- @cards}
          title={card.title}
          description={card.description}
          preview_html={card.preview_html}
          snippet={card.snippet}
          shadcn_component_url={card.shadcn_component_url}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  defp button_group_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Actions.button_group>
        <Actions.button>Deploy</Actions.button>
        <Actions.button variant={:outline}>Rollback</Actions.button>
      </Actions.button_group>
      """)

    snippet = """
    <.button_group>
      <.button>Deploy</.button>
      <.button variant={:outline}>Rollback</.button>
    </.button_group>
    """

    %{
      title: "button_group",
      description: "Grouped primary + secondary actions.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/button"
    }
  end

  defp form_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Forms.field>
        <:label>
          <Forms.label for="site-email">Team email</Forms.label>
        </:label>
        <Forms.input id="site-email" placeholder="team@example.com" />
        <:description>Used for release announcements.</:description>
        <div class="pt-2">
          <Forms.switch id="site-updates" checked={true}>Send release updates</Forms.switch>
        </div>
      </Forms.field>
      """)

    snippet = """
    <.field>
      <:label><.label for="site-email">Team email</.label></:label>
      <.input id="site-email" placeholder="team@example.com" />
      <:description>Used for release announcements.</:description>
    </.field>
    """

    %{
      title: "field",
      description: "Label + input + helper text using the shared token model.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/form"
    }
  end

  defp alert_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Feedback.alert>
        <Icons.icon name="circle-alert" class="size-4" />
        <Feedback.alert_title>Release ready</Feedback.alert_title>
        <Feedback.alert_description>
          All quality checks passed. Publish when ready.
        </Feedback.alert_description>
      </Feedback.alert>
      """)

    snippet = """
    <.alert>
      <.icon name="circle-alert" class="size-4" />
      <.alert_title>Release ready</.alert_title>
      <.alert_description>All quality checks passed.</.alert_description>
    </.alert>
    """

    %{
      title: "alert",
      description: "Status messaging aligned with upstream alert patterns.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/alert"
    }
  end

  defp tabs_example_card(shadcn_url) do
    assigns = %{}

    preview =
      to_html(~H"""
      <Navigation.tabs value="overview">
        <:trigger value="overview">Overview</:trigger>
        <:trigger value="api">API</:trigger>
        <:content value="overview">Use components directly in HEEx templates.</:content>
        <:content value="api">Typed attrs/slots with compile-time checks.</:content>
      </Navigation.tabs>
      """)

    snippet = """
    <.tabs value="overview">
      <:trigger value="overview">Overview</:trigger>
      <:trigger value="api">API</:trigger>
      <:content value="overview">Use components in HEEx.</:content>
      <:content value="api">Typed attrs/slots with compile-time checks.</:content>
    </.tabs>
    """

    %{
      title: "tabs",
      description: "Tab primitives with server-driven active state.",
      preview_html: preview,
      snippet: snippet,
      shadcn_component_url: "#{shadcn_url}/components/tabs"
    }
  end

  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :preview_html, :string, required: true
  attr :snippet, :string, required: true
  attr :shadcn_component_url, :string, required: true

  defp marketing_example_card(assigns) do
    ~H"""
    <Layout.panel class="bp-example-card h-full divide-y">
      <div class="p-4">
        <h4 class="bp-mono text-sm font-medium text-muted-foreground">{@title}</h4>
        <p class="text-muted-foreground mt-1 text-sm">{@description}</p>
      </div>

      <div
        data-slot="preview"
        class="bg-background flex min-h-[7rem] flex-1 items-center justify-center p-4"
      >
        {rendered(@preview_html)}
      </div>

      <details data-slot="code-details" class="relative min-w-0 border-t">
        <summary
          data-slot="code-summary"
          class="bp-mono flex cursor-pointer items-center gap-2 px-4 py-2 text-xs text-muted-foreground hover:text-foreground select-none"
        >
          <Icons.icon name="code" class="size-3.5" />
          <span>View source</span>
        </summary>
        <Docs.docs_code_block
          source={@snippet}
          language={:heex}
          pre_class="m-0 min-w-0 max-w-full max-h-56 overflow-x-auto overflow-y-auto p-4 pr-12 text-xs leading-4"
        />
      </details>
    </Layout.panel>
    """
  end

  defp install_html(version, docs_path) do
    deps_code = """
    def deps do
      [
        {:cinder_ui, "~> #{version}"},
        {:lucide_icons, "~> 2.0"} # optional, recommended for <.icon />
      ]
    end
    """

    terminal_code = """
    mix deps.get
    mix cinder_ui.install --skip-existing
    """

    assigns = %{
      deps_code: deps_code,
      terminal_code: terminal_code,
      install_docs_path: Path.join(docs_path, "install/")
    }

    ~H"""
    <section id="install">
      <div class="bp-section-connector" aria-hidden="true"></div>
      <p class="bp-section-label">// install</p>
      <h2 class="bp-heading text-2xl font-semibold tracking-tight mt-2">Quick start</h2>
      <p class="text-sm text-muted-foreground mt-1">
        Full guide:
        <a href={@install_docs_path} class="underline underline-offset-4">installation docs</a>.
      </p>
      <div class="bp-install-steps mt-6 space-y-6">
        <div class="bp-install-step">
          <p class="bp-mono text-sm font-medium text-foreground">
            <span class="text-muted-foreground">01</span>
            &nbsp;Add dependencies to <code class="inline-code">mix.exs</code>
          </p>
          <div class="mt-2">
            <Docs.docs_code_block
              source={@deps_code}
              language={:elixir}
              pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
            />
          </div>
        </div>
        <div class="bp-install-step">
          <p class="bp-mono text-sm font-medium text-foreground">
            <span class="text-muted-foreground">02</span>
            &nbsp;Fetch and install
          </p>
          <div class="mt-2 bp-terminal-block">
            <Docs.docs_code_block
              source={@terminal_code}
              language={:bash}
              pre_class="relative rounded-lg border bg-muted/30 px-4 py-3 text-sm"
            />
          </div>
        </div>
      </div>
    </section>
    """
    |> to_html()
  end

  defp features_html(shadcn_url) do
    assigns = %{
      features: [
        %{
          icon: "blocks",
          title: "Phoenix-native",
          body: "Typed HEEx function components with predictable attrs and slots."
        },
        %{
          icon: "terminal",
          title: "Fast setup",
          body: "One command wires Tailwind, CSS tokens, and optional LiveView hooks."
        },
        %{
          icon: "paintbrush",
          title: "shadcn-aligned",
          body:
            "API surface and CSS variables match <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions."
        },
        %{
          icon: "circle-check",
          title: "Battle-tested",
          body: "Unit, browser, and visual regression coverage for every component."
        }
      ]
    }

    ~H"""
    <section id="features">
      <div class="bp-section-connector" aria-hidden="true"></div>
      <p class="bp-section-label">// features</p>
      <div class="grid gap-3 mt-4 sm:grid-cols-2 lg:grid-cols-4">
        <.marketing_feature_card
          :for={feature <- @features}
          icon={feature.icon}
          title={feature.title}
          body_html={feature.body}
        />
      </div>
    </section>
    """
    |> to_html()
  end

  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :body_html, :string, required: true

  defp marketing_feature_card(assigns) do
    ~H"""
    <Layout.card class="bp-feature-card">
      <Layout.card_content class="flex flex-col gap-2 p-4">
        <div class="flex items-center gap-2">
          <Icons.icon name={@icon} class="size-4 text-muted-foreground" />
          <span class="bp-mono text-sm font-medium">{@title}</span>
        </div>
        <Layout.card_description class="text-sm">
          {rendered(@body_html)}
        </Layout.card_description>
      </Layout.card_content>
    </Layout.card>
    """
  end

  defp footer_html(github_url, hex_url, hexdocs_url, shadcn_url, docs_path) do
    assigns = %{
      github_url: github_url,
      hex_url: hex_url,
      hexdocs_url: hexdocs_url,
      shadcn_url: shadcn_url,
      docs_path: docs_path
    }

    ~H"""
    <footer class="bp-footer mt-16 border-t pt-8 pb-12">
      <div class="flex flex-col gap-6 sm:flex-row sm:items-start sm:justify-between">
        <div class="space-y-2">
          <p class="bp-mono text-sm font-medium text-foreground">Cinder UI</p>
          <p class="text-sm text-muted-foreground max-w-md">
            An independent project based on
            <a
              href={@shadcn_url}
              target="_blank"
              rel="noopener noreferrer"
              class="underline underline-offset-4"
            >shadcn/ui</a>
            patterns, built for Elixir, Phoenix, and LiveView by
            <a
              href="https://levibuzolic.com"
              target="_blank"
              rel="noopener noreferrer"
              class="underline underline-offset-4"
            >Levi Buzolic</a>.
          </p>
        </div>
        <div class="flex flex-wrap items-center gap-x-4 gap-y-2 text-sm text-muted-foreground">
          <a :if={is_binary(@github_url) and @github_url != ""} href={@github_url} target="_blank" rel="noopener noreferrer" class="hover:text-foreground transition-colors">GitHub</a>
          <a :if={is_binary(@hex_url) and @hex_url != ""} href={@hex_url} target="_blank" rel="noopener noreferrer" class="hover:text-foreground transition-colors">Hex</a>
          <a :if={is_binary(@hexdocs_url) and @hexdocs_url != ""} href={@hexdocs_url} target="_blank" rel="noopener noreferrer" class="hover:text-foreground transition-colors">HexDocs</a>
          <a href={@docs_path} class="hover:text-foreground transition-colors">Docs</a>
        </div>
      </div>
      <div class="mt-6 flex items-center gap-2 text-xs text-muted-foreground">
        <span>Press</span>
        <kbd class="bp-kbd">&#8984;K</kbd>
        <span>to search components</span>
      </div>
    </footer>
    """
    |> to_html()
  end

  defp theme_bootstrap_script do
    "<script>\n#{template!("theme_bootstrap.js")}\n</script>"
  end

  defp template!(name), do: File.read!(Path.join(@template_dir, name))

  defp to_html(rendered) do
    rendered
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp rendered(html) when is_binary(html), do: Phoenix.HTML.raw(html)
end
