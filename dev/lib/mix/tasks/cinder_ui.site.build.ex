defmodule Mix.Tasks.CinderUi.Site.Build do
  @shortdoc "Builds a static developer/marketing site with bundled docs"
  @moduledoc """
  Builds a static developer/marketing site for Cinder UI.

  The generated site includes:

  - `index.html` marketing/developer landing page
  - bundled static component docs under `docs/` (from `mix cinder_ui.docs.build`)

  Output can be deployed to GitHub Pages, Cloudflare Pages, Vercel, Netlify, S3, or any static host.

  ## Options

    * `--output` - output directory (default: `dist/site`)
    * `--clean` - remove output directory before generating
    * `--github-url` - repository URL override
    * `--hexdocs-url` - HexDocs URL override

  ## Examples

      mix cinder_ui.site.build
      mix cinder_ui.site.build --output public --clean
  """

  use Mix.Task

  alias CinderUI.Components.Actions
  alias CinderUI.Components.DataDisplay
  alias CinderUI.Components.Feedback
  alias CinderUI.Components.Forms
  alias CinderUI.Components.Layout
  alias CinderUI.Components.Navigation
  alias CinderUI.Icons
  alias Phoenix.HTML
  alias Phoenix.HTML.Safe

  @template_dir Path.expand("../../../../priv/site_templates", __DIR__)

  @switches [
    output: :string,
    clean: :boolean,
    github_url: :string,
    hexdocs_url: :string,
    help: :boolean
  ]

  @impl true
  def run(argv) do
    argv
    |> parse_opts()
    |> dispatch()
  end

  defp parse_opts(argv) do
    {opts, _, _} = OptionParser.parse(argv, strict: @switches)

    %{
      output: opts[:output] || "dist/site",
      clean?: opts[:clean] || false,
      github_url: opts[:github_url],
      hexdocs_url: opts[:hexdocs_url],
      help?: opts[:help] || false
    }
  end

  defp dispatch(%{help?: true}), do: Mix.shell().info(@moduledoc)

  defp dispatch(opts), do: build_site!(opts)

  defp build_site!(opts) do
    output_dir = Path.expand(opts.output, File.cwd!())
    project = Mix.Project.config()
    github_url = opts.github_url || to_string(project[:source_url] || "")
    hexdocs_url = opts.hexdocs_url || "https://hexdocs.pm/cinder_ui"
    version = to_string(project[:version] || "0.0.0")
    theme_css = theme_css()

    maybe_clean_output!(output_dir, opts.clean?)
    File.mkdir_p!(output_dir)

    docs_dir = Path.join(output_dir, "docs")
    build_docs_site!(docs_dir, github_url)

    assets_dir = Path.join(output_dir, "assets")
    File.mkdir_p!(assets_dir)

    File.write!(
      Path.join(output_dir, "index.html"),
      index_html(version, github_url, hexdocs_url, theme_css)
    )

    File.write!(Path.join(assets_dir, "site.css"), site_css())
    File.write!(Path.join(output_dir, ".nojekyll"), "")

    Mix.shell().info("generated #{relative(output_dir)}")
    Mix.shell().info("open #{relative(Path.join(output_dir, "index.html"))} in a browser")
  end

  defp maybe_clean_output!(output_dir, true) do
    if File.dir?(output_dir), do: File.rm_rf!(output_dir)
  end

  defp maybe_clean_output!(_output_dir, false), do: :ok

  defp build_docs_site!(docs_dir, github_url) do
    Mix.Task.reenable("cinder_ui.docs.build")

    Mix.Task.run("cinder_ui.docs.build", [
      "--output",
      docs_dir,
      "--clean",
      "--home-url",
      "../index.html",
      "--github-url",
      github_url,
      "--hex-package-url",
      "https://hex.pm/packages/cinder_ui"
    ])
  end

  defp theme_css do
    "assets/css/cinder_ui.css"
    |> File.read!()
    |> String.replace(~r/^@import\s+"tailwindcss";\n?/m, "")
    |> String.replace(~r/^@plugin\s+"tailwindcss-animate";\n?/m, "")
  end

  defp index_html(version, github_url, hexdocs_url, theme_css) do
    shadcn_url = "https://ui.shadcn.com/docs"

    assigns = [
      theme_bootstrap_script: theme_bootstrap_script(),
      theme_css: theme_css,
      header_controls_html: header_controls_html(),
      shadcn_url: shadcn_url,
      hero_html: hero_html(version, shadcn_url),
      component_examples_html: component_examples_html(shadcn_url),
      install_html: install_html(version),
      theme_tokens_html: theme_tokens_html(),
      features_html: features_html(shadcn_url),
      links_html: links_html(github_url, hexdocs_url, shadcn_url),
      theme_toggle_script: theme_toggle_script()
    ]

    "index.html.eex"
    |> template!()
    |> EEx.eval_string(assigns)
  end

  defp header_controls_html do
    """
    <div class=\"flex flex-wrap items-center gap-2\">
      #{header_nav_html()}
      #{theme_toggle_html()}
    </div>
    """
  end

  defp header_nav_html do
    render_component(Navigation, :navigation_menu, %{
      item: [
        nav_item("Component docs", "./docs/index.html", true),
        nav_item("Examples", "#examples", false),
        nav_item("Install", "#install", false),
        nav_item("Links", "#links", false)
      ]
    })
  end

  defp theme_toggle_html do
    light_button =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        class: "theme-toggle-btn",
        rest: %{
          "data-site-theme" => "light",
          "aria-label" => "Switch to light mode",
          "type" => "button"
        },
        inner_block: slot("Light")
      })

    dark_button =
      render_component(Actions, :button, %{
        variant: :outline,
        size: :sm,
        class: "theme-toggle-btn",
        rest: %{
          "data-site-theme" => "dark",
          "aria-label" => "Switch to dark mode",
          "type" => "button"
        },
        inner_block: slot("Dark")
      })

    render_component(Actions, :button_group, %{
      class: "site-theme-toggle",
      inner_block: slot(light_button <> dark_button)
    })
  end

  defp hero_html(version, shadcn_url) do
    hero_badge =
      render_component(Feedback, :badge, %{
        variant: :secondary,
        inner_block: slot("Shadcn-style CSS tokens")
      })

    primary_cta =
      render_component(Actions, :button, %{
        as: "a",
        rest: %{href: "./docs/index.html"},
        inner_block: slot("Browse Component Library")
      })

    secondary_cta =
      render_component(Actions, :button, %{
        as: "a",
        variant: :outline,
        rest: %{href: "#install"},
        inner_block: slot("Quick Start")
      })

    summary_title =
      render_component(Layout, :card_title, %{inner_block: slot("Project snapshot")})

    summary_description =
      render_component(Layout, :card_description, %{
        inner_block: slot("Drop-in for existing Phoenix + LiveView projects.")
      })

    summary_header =
      render_component(Layout, :card_header, %{
        inner_block: slot(summary_title <> summary_description)
      })

    summary_content =
      render_component(Layout, :card_content, %{
        inner_block:
          slot("""
          <ul class=\"space-y-1 text-sm text-muted-foreground\">
            <li><strong class=\"text-foreground\">Current version:</strong> v#{version}</li>
            <li><strong class=\"text-foreground\">Theme baseline:</strong> neutral semantic tokens + <code>--radius</code> defaults</li>
            <li><strong class=\"text-foreground\">Integration:</strong> <code>mix cinder_ui.install</code> for existing Phoenix assets</li>
          </ul>
          """)
      })

    summary_card =
      render_component(Layout, :card, %{
        class: "h-full",
        inner_block: slot(summary_header <> summary_content)
      })

    """
    <section>
      <div class="grid gap-6 lg:grid-cols-[1.35fr_1fr]">
        <div class="space-y-4">
          #{hero_badge}
          <h1 class="text-4xl font-semibold tracking-tight sm:text-5xl">
            <a href="#{shadcn_url}" target="_blank" rel="noopener noreferrer" class="underline underline-offset-4">shadcn/ui</a>
            component patterns, packaged for Phoenix + LiveView.
          </h1>
          <p class="max-w-2xl text-base text-muted-foreground">
            Cinder UI provides server-rendered components, typed attrs/slots,
            and installer automation that keep parity with
            <a href="#{shadcn_url}" target="_blank" rel="noopener noreferrer" class="underline underline-offset-4">shadcn/ui</a>
            conventions while fitting Phoenix conventions.
          </p>
          <div class="flex flex-wrap gap-2">
            #{primary_cta}
            #{secondary_cta}
          </div>
        </div>

        #{summary_card}
      </div>
    </section>
    """
  end

  defp component_examples_html(shadcn_url) do
    """
    <section id="examples" class="space-y-4">
      <div class="flex flex-wrap items-baseline justify-between gap-2">
        <h2 class="text-2xl font-semibold tracking-tight">Component examples on the homepage</h2>
        <a href="#{shadcn_url}" target="_blank" rel="noopener noreferrer" class="text-sm text-muted-foreground underline underline-offset-4">Reference: shadcn/ui docs ↗</a>
      </div>

      <p class="text-sm text-muted-foreground">
        These previews are rendered with Cinder UI components so users can immediately see the API and visual system they will use in production.
      </p>

      <div class="grid gap-4 md:grid-cols-2">
        #{button_group_example_card(shadcn_url)}
        #{form_example_card(shadcn_url)}
        #{alert_example_card(shadcn_url)}
        #{tabs_example_card(shadcn_url)}
      </div>
    </section>
    """
  end

  defp button_group_example_card(shadcn_url) do
    preview =
      render_component(Actions, :button_group, %{
        inner_block:
          slot(
            render_component(Actions, :button, %{inner_block: slot("Deploy")}) <>
              "\n" <>
              render_component(Actions, :button, %{
                variant: :outline,
                inner_block: slot("Rollback")
              })
          )
      })

    snippet = """
    <.button_group>
      <.button>Deploy</.button>
      <.button variant={:outline}>Rollback</.button>
    </.button_group>
    """

    example_card(
      "Actions.button_group",
      "Grouped primary + secondary actions.",
      preview,
      snippet,
      "#{shadcn_url}/components/button"
    )
  end

  defp form_example_card(shadcn_url) do
    label_html =
      render_component(Forms, :label, %{for: "site-email", inner_block: slot("Team email")})

    input_html =
      render_component(Forms, :input, %{id: "site-email", placeholder: "team@example.com"})

    switch_html =
      render_component(Forms, :switch, %{
        id: "site-updates",
        checked: true,
        inner_block: slot("Send release updates")
      })

    preview =
      render_component(Forms, :field, %{
        label: slot(label_html),
        description: slot("Used for release announcements."),
        inner_block: slot(input_html <> "<div class=\"pt-2\">#{switch_html}</div>")
      })

    snippet = """
    <.field>
      <:label><.label for="site-email">Team email</.label></:label>
      <.input id="site-email" placeholder="team@example.com" />
      <:description>Used for release announcements.</:description>
    </.field>
    """

    example_card(
      "Forms.field",
      "Label + input + helper text using the shared token model.",
      preview,
      snippet,
      "#{shadcn_url}/components/form"
    )
  end

  defp alert_example_card(shadcn_url) do
    alert_title = render_component(Feedback, :alert_title, %{inner_block: slot("Release ready")})

    alert_description =
      render_component(Feedback, :alert_description, %{
        inner_block: slot("All quality checks passed. Publish when ready.")
      })

    preview =
      render_component(Feedback, :alert, %{
        inner_block:
          slot("""
          #{render_component(Icons, :icon, %{name: "circle-alert", class: "size-4"})}
          #{alert_title}
          #{alert_description}
          """)
      })

    snippet = """
    <.alert>
      <.icon name="circle-alert" class="size-4" />
      <.alert_title>Release ready</.alert_title>
      <.alert_description>All quality checks passed.</.alert_description>
    </.alert>
    """

    example_card(
      "Feedback.alert",
      "Status messaging aligned with upstream alert patterns.",
      preview,
      snippet,
      "#{shadcn_url}/components/alert"
    )
  end

  defp tabs_example_card(shadcn_url) do
    preview =
      render_component(Navigation, :tabs, %{
        value: "overview",
        trigger: [
          %{value: "overview", inner_block: fn _, _ -> "Overview" end},
          %{value: "api", inner_block: fn _, _ -> "API" end}
        ],
        content: [
          %{
            value: "overview",
            inner_block: fn _, _ -> "Use components directly in HEEx templates." end
          },
          %{
            value: "api",
            inner_block: fn _, _ -> "Typed attrs/slots with compile-time checks." end
          }
        ]
      })

    snippet = """
    <.tabs value="overview">
      <:trigger value="overview">Overview</:trigger>
      <:trigger value="api">API</:trigger>
      <:content value="overview">Use components in HEEx.</:content>
      <:content value="api">Typed attrs/slots with compile-time checks.</:content>
    </.tabs>
    """

    example_card(
      "Navigation.tabs",
      "Tab primitives with server-driven active state.",
      preview,
      snippet,
      "#{shadcn_url}/components/tabs"
    )
  end

  defp example_card(title, description, preview_html, snippet, shadcn_component_url) do
    card_title = render_component(Layout, :card_title, %{inner_block: slot(title)})

    card_description =
      render_component(Layout, :card_description, %{inner_block: slot(description)})

    header =
      render_component(Layout, :card_header, %{inner_block: slot(card_title <> card_description)})

    content =
      render_component(Layout, :card_content, %{
        inner_block:
          slot("""
          <div class=\"rounded-lg border bg-background p-4\">#{preview_html}</div>
          <div class=\"mt-3\">#{render_component(DataDisplay, :code_block, %{inner_block: slot(escape(snippet))})}</div>
          """)
      })

    footer =
      render_component(Layout, :card_footer, %{
        class: "justify-between gap-2",
        inner_block:
          slot("""
          <span class=\"text-xs text-muted-foreground\">Rendered using Cinder UI components</span>
          <a href=\"#{shadcn_component_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"text-xs underline underline-offset-4\">shadcn/ui reference ↗</a>
          """)
      })

    render_component(Layout, :card, %{inner_block: slot(header <> content <> footer)})
  end

  defp install_html(version) do
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

    deps_block =
      render_component(DataDisplay, :code_block, %{inner_block: slot(escape(deps_code))})

    terminal_block =
      render_component(DataDisplay, :code_block, %{inner_block: slot(escape(terminal_code))})

    """
    <section id="install" class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">Install in your Phoenix app</h2>
      <div class="space-y-2">
        <p class="text-sm font-medium text-foreground">1) Add dependencies to <code>mix.exs</code></p>
        #{deps_block}
      </div>
      <div class="space-y-2">
        <p class="text-sm font-medium text-foreground">2) Install and run setup commands in your terminal</p>
        #{terminal_block}
      </div>
    </section>
    """
  end

  defp theme_tokens_html do
    tokens_code = """
    :root {
      --background: oklch(1 0 0);
      --foreground: oklch(0.145 0 0);
      --card: oklch(1 0 0);
      --card-foreground: oklch(0.145 0 0);
      --popover: oklch(1 0 0);
      --popover-foreground: oklch(0.145 0 0);
      --primary: oklch(0.205 0 0);
      --primary-foreground: oklch(0.985 0 0);
      --secondary: oklch(0.97 0 0);
      --secondary-foreground: oklch(0.205 0 0);
      --muted: oklch(0.97 0 0);
      --muted-foreground: oklch(0.556 0 0);
      --accent: oklch(0.97 0 0);
      --accent-foreground: oklch(0.205 0 0);
      --destructive: oklch(0.577 0.245 27.325);
      --destructive-foreground: oklch(0.985 0 0);
      --border: oklch(0.922 0 0);
      --input: oklch(0.922 0 0);
      --ring: oklch(0.708 0 0);
      --radius: 0.75rem;
    }

    .dark {
      --background: oklch(0.145 0 0);
      --foreground: oklch(0.985 0 0);
      --card: oklch(0.205 0 0);
      --card-foreground: oklch(0.985 0 0);
      --popover: oklch(0.205 0 0);
      --popover-foreground: oklch(0.985 0 0);
      --primary: oklch(0.922 0 0);
      --primary-foreground: oklch(0.205 0 0);
      --secondary: oklch(0.269 0 0);
      --secondary-foreground: oklch(0.985 0 0);
      --muted: oklch(0.269 0 0);
      --muted-foreground: oklch(0.708 0 0);
      --accent: oklch(0.269 0 0);
      --accent-foreground: oklch(0.985 0 0);
      --destructive: oklch(0.704 0.191 22.216);
      --destructive-foreground: oklch(0.985 0 0);
      --border: oklch(1 0 0 / 10%);
      --input: oklch(1 0 0 / 15%);
      --ring: oklch(0.556 0 0);
    }
    """

    tokens_block =
      render_component(DataDisplay, :code_block, %{inner_block: slot(escape(tokens_code))})

    """
    <section id="tokens" class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">Configure tokens like shadcn/ui</h2>
      <p class="text-sm text-muted-foreground">
        Customize your theme in <code>assets/css/app.css</code> by overriding semantic CSS variables.
        Radius is controlled via <code>--radius</code>; component radii are derived from it automatically.
      </p>
      #{tokens_block}
    </section>
    """
  end

  defp features_html(shadcn_url) do
    """
    <section class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">What you get</h2>
      <div class="grid gap-4 md:grid-cols-2">
        #{feature_card("Phoenix-native API", "Typed HEEx function components with predictable attrs/slots and composable primitives.")}
        #{feature_card("Fast app integration", "One command setup for Tailwind source wiring, component CSS, and optional LiveView hooks in existing projects.")}
        #{feature_card("shadcn-aligned styles", "Broad API surface aligned with <a href=\"#{shadcn_url}\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"underline underline-offset-4\">shadcn/ui</a> conventions and token semantics.")}
        #{feature_card("Production confidence", "Unit, browser, and visual regression coverage keeps components stable as your app evolves.")}
      </div>
    </section>
    """
  end

  defp feature_card(title, body_html) do
    card_title = render_component(Layout, :card_title, %{inner_block: slot(title)})
    card_header = render_component(Layout, :card_header, %{inner_block: slot(card_title)})

    card_content =
      render_component(Layout, :card_content, %{
        inner_block: slot("<p class=\"text-sm text-muted-foreground\">#{body_html}</p>")
      })

    render_component(Layout, :card, %{inner_block: slot(card_header <> card_content)})
  end

  defp links_html(github_url, hexdocs_url, shadcn_url) do
    github_button =
      render_component(Actions, :button, %{
        as: "a",
        variant: :outline,
        rest: %{href: github_url, target: "_blank", rel: "noopener noreferrer"},
        inner_block: slot("GitHub repository")
      })

    hexdocs_button =
      render_component(Actions, :button, %{
        as: "a",
        variant: :outline,
        rest: %{href: hexdocs_url, target: "_blank", rel: "noopener noreferrer"},
        inner_block: slot("HexDocs")
      })

    docs_button =
      render_component(Actions, :button, %{
        as: "a",
        rest: %{href: "./docs/index.html"},
        inner_block: slot("Component reference")
      })

    shadcn_button =
      render_component(Actions, :button, %{
        as: "a",
        variant: :ghost,
        rest: %{href: shadcn_url, target: "_blank", rel: "noopener noreferrer"},
        inner_block: slot("shadcn/ui docs")
      })

    """
    <section id="links" class="space-y-3">
      <h2 class="text-2xl font-semibold tracking-tight">Project links</h2>
      <div class="flex flex-wrap gap-2">
        #{github_button}
        #{hexdocs_button}
        #{docs_button}
        #{shadcn_button}
      </div>
    </section>
    """
  end

  defp nav_item(label, href, active) do
    %{href: href, active: active, inner_block: fn _, _ -> label end}
  end

  defp render_component(module, function, assigns) do
    assigns = Map.put_new(assigns, :__changed__, %{})

    module
    |> apply(function, [assigns])
    |> Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  defp slot(content) do
    [
      %{
        inner_block: fn _, _ -> HTML.raw(content) end
      }
    ]
  end

  defp site_css do
    template!("site.css")
  end

  defp theme_bootstrap_script do
    """
    <script>
    #{template!("theme_bootstrap.js")}
    </script>
    """
  end

  defp theme_toggle_script do
    """
    <script>
    #{template!("theme_toggle.js")}
    </script>
    """
  end

  defp template!(name), do: File.read!(Path.join(@template_dir, name))

  defp relative(path), do: Path.relative_to(path, File.cwd!())

  defp escape(text), do: text |> HTML.html_escape() |> HTML.safe_to_string()
end
