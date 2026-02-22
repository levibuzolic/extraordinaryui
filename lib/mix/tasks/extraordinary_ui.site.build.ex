defmodule Mix.Tasks.ExtraordinaryUi.Site.Build do
  @shortdoc "Builds a static developer/marketing site with bundled docs"
  @moduledoc """
  Builds a static developer/marketing site for Extraordinary UI.

  The generated site includes:

  - `index.html` marketing/developer landing page
  - bundled static component docs under `docs/` (from `mix extraordinary_ui.docs.build`)

  Output can be deployed to GitHub Pages, Cloudflare Pages, Vercel, Netlify, S3, or any static host.

  ## Options

    * `--output` - output directory (default: `dist/site`)
    * `--clean` - remove output directory before generating
    * `--github-url` - repository URL override
    * `--hexdocs-url` - HexDocs URL override

  ## Examples

      mix extraordinary_ui.site.build
      mix extraordinary_ui.site.build --output public --clean
  """

  use Mix.Task

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
    hexdocs_url = opts.hexdocs_url || "https://hexdocs.pm/extraordinary_ui"
    version = to_string(project[:version] || "0.0.0")

    maybe_clean_output!(output_dir, opts.clean?)
    File.mkdir_p!(output_dir)

    docs_dir = Path.join(output_dir, "docs")
    build_docs_site!(docs_dir)

    assets_dir = Path.join(output_dir, "assets")
    File.mkdir_p!(assets_dir)

    File.write!(
      Path.join(output_dir, "index.html"),
      index_html(version, github_url, hexdocs_url)
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

  defp build_docs_site!(docs_dir) do
    Mix.Task.reenable("extraordinary_ui.docs.build")
    Mix.Task.run("extraordinary_ui.docs.build", ["--output", docs_dir, "--clean"])
  end

  defp index_html(version, github_url, hexdocs_url) do
    """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Extraordinary UI</title>
        <meta
          name="description"
          content="Shadcn-inspired UI component library for Phoenix + LiveView."
        />
        <link rel="stylesheet" href="./assets/site.css" />
      </head>
      <body>
        <header class="site-header">
          <div class="container header-inner">
            <a class="brand" href="./index.html">Extraordinary UI</a>
            <nav class="header-nav" aria-label="Primary">
              <a href="./docs/index.html">Component docs</a>
              <a href="#install">Install</a>
              <a href="#links">Links</a>
            </nav>
          </div>
        </header>

        <main>
          <section class="hero">
            <div class="container hero-grid">
              <div>
                <p class="kicker">Phoenix + LiveView UI Library</p>
                <h1>Shadcn-style components for Elixir teams.</h1>
                <p class="lede">
                  Extraordinary UI provides server-rendered Phoenix components with shadcn-style
                  design tokens, compositional patterns, installer tooling, static docs, and browser tests.
                </p>
                <div class="hero-actions">
                  <a class="btn btn-primary" href="./docs/index.html">Browse Component Library</a>
                  <a class="btn btn-secondary" href="#install">Quick Start</a>
                </div>
              </div>

              <aside class="hero-panel" aria-label="Project summary">
                <p><strong>Current version:</strong> v#{version}</p>
                <p><strong>Static docs:</strong> included at <code>/docs</code></p>
                <p><strong>Hex package:</strong> <code>extraordinary_ui</code></p>
              </aside>
            </div>
          </section>

          <section id="install" class="section">
            <div class="container">
              <h2>Install</h2>
              <p>Add the dependency, install assets, and render components in HEEx templates.</p>
              <pre><code>def deps do
      [
        {:extraordinary_ui, "~> #{version}"}
      ]
    end

    mix deps.get
    mix extraordinary_ui.install</code></pre>
            </div>
          </section>

          <section class="section section-alt">
            <div class="container">
              <h2>What You Get</h2>
              <ul class="feature-grid">
                <li>
                  <h3>Component Coverage</h3>
                  <p>Broad shadcn-inspired API surface with Phoenix-first composability.</p>
                </li>
                <li>
                  <h3>Static Docs + Catalog</h3>
                  <p>Fully static component docs and HEEx snippets; host anywhere.</p>
                </li>
                <li>
                  <h3>Installer & Theme Tokens</h3>
                  <p>Tailwind setup automation with token-driven customization.</p>
                </li>
                <li>
                  <h3>Quality Gates</h3>
                  <p>Unit tests, browser tests, and visual regression coverage via Playwright.</p>
                </li>
              </ul>
            </div>
          </section>

          <section id="links" class="section">
            <div class="container">
              <h2>Project Links</h2>
              <ul class="links">
                <li><a href="#{github_url}" target="_blank" rel="noopener noreferrer">GitHub repository</a></li>
                <li><a href="#{hexdocs_url}" target="_blank" rel="noopener noreferrer">HexDocs (published docs link)</a></li>
                <li><a href="./docs/index.html">Static component library</a></li>
              </ul>
            </div>
          </section>
        </main>

        <footer class="site-footer">
          <div class="container footer-inner">
            <p>Extraordinary UI is open source and deployable on any static host.</p>
          </div>
        </footer>
      </body>
    </html>
    """
  end

  defp site_css do
    """
    :root {
      --bg: #0b1020;
      --surface: #111a33;
      --surface-alt: #0f1730;
      --text: #f4f7ff;
      --muted: #b7c0dd;
      --border: #2a365f;
      --accent: #7dd3fc;
      --accent-2: #22d3ee;
      --mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
    }

    * {
      box-sizing: border-box;
    }

    html,
    body {
      margin: 0;
      padding: 0;
      background: radial-gradient(1200px 600px at 10% -20%, #1f2d57 0%, var(--bg) 55%);
      color: var(--text);
      font-family: "Inter", "Avenir Next", "Segoe UI", sans-serif;
      line-height: 1.5;
    }

    a {
      color: var(--accent);
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    .container {
      width: min(1120px, calc(100% - 2rem));
      margin: 0 auto;
    }

    .site-header {
      position: sticky;
      top: 0;
      z-index: 20;
      backdrop-filter: blur(10px);
      border-bottom: 1px solid var(--border);
      background: color-mix(in oklab, var(--bg) 82%, black 18%);
    }

    .header-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0.75rem 0;
    }

    .brand {
      font-weight: 700;
      letter-spacing: 0.02em;
    }

    .header-nav {
      display: flex;
      gap: 1rem;
      font-size: 0.95rem;
    }

    .hero {
      padding: 4.5rem 0 3rem;
    }

    .hero-grid {
      display: grid;
      gap: 1.5rem;
      grid-template-columns: 1.3fr 1fr;
      align-items: start;
    }

    .kicker {
      margin: 0;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      font-size: 0.8rem;
      color: var(--accent-2);
      font-weight: 700;
    }

    h1 {
      margin: 0.5rem 0 0;
      font-size: clamp(2rem, 4vw, 3.4rem);
      line-height: 1.1;
      letter-spacing: -0.02em;
    }

    .lede {
      color: var(--muted);
      max-width: 68ch;
      margin-top: 1rem;
    }

    .hero-actions {
      display: flex;
      gap: 0.75rem;
      flex-wrap: wrap;
      margin-top: 1.25rem;
    }

    .btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: 0.6rem;
      padding: 0.6rem 0.95rem;
      border: 1px solid transparent;
      font-weight: 600;
    }

    .btn-primary {
      background: linear-gradient(120deg, #22d3ee, #7dd3fc);
      color: #001220;
    }

    .btn-secondary {
      border-color: var(--border);
      color: var(--text);
      background: var(--surface);
    }

    .hero-panel {
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 0.9rem;
      padding: 1rem;
      color: var(--muted);
    }

    .hero-panel code {
      font-family: var(--mono);
      color: #d1e4ff;
    }

    .section {
      padding: 2rem 0;
    }

    .section-alt {
      background: color-mix(in oklab, var(--surface-alt) 75%, transparent);
      border-top: 1px solid var(--border);
      border-bottom: 1px solid var(--border);
    }

    h2 {
      margin: 0 0 0.5rem;
      font-size: 1.6rem;
      letter-spacing: -0.01em;
    }

    pre {
      overflow-x: auto;
      padding: 1rem;
      border: 1px solid var(--border);
      background: var(--surface);
      border-radius: 0.75rem;
    }

    code {
      font-family: var(--mono);
      font-size: 0.9rem;
    }

    .feature-grid {
      list-style: none;
      padding: 0;
      margin: 1rem 0 0;
      display: grid;
      gap: 0.8rem;
      grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .feature-grid li {
      border: 1px solid var(--border);
      border-radius: 0.75rem;
      padding: 0.85rem;
      background: var(--surface);
    }

    .feature-grid h3 {
      margin: 0;
      font-size: 1rem;
    }

    .feature-grid p {
      margin: 0.45rem 0 0;
      color: var(--muted);
      font-size: 0.95rem;
    }

    .links {
      margin: 0.8rem 0 0;
      padding: 0;
      list-style: none;
      display: grid;
      gap: 0.5rem;
      font-size: 1.05rem;
    }

    .site-footer {
      border-top: 1px solid var(--border);
      margin-top: 2rem;
    }

    .footer-inner {
      padding: 1rem 0 2rem;
      color: var(--muted);
      font-size: 0.95rem;
    }

    @media (max-width: 960px) {
      .hero-grid,
      .feature-grid {
        grid-template-columns: 1fr;
      }
    }
    """
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end
