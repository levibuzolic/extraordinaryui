# Extraordinary UI

Shadcn-inspired UI components for Phoenix + LiveView.

Extraordinary UI is a Hex-oriented component library that ports shadcn/ui design patterns, classes, tokens, and compositional structure into Elixir function components.

The project is intentionally aligned with:

- [shadcn/ui docs](https://ui.shadcn.com/docs)
- [shadcn/ui repository](https://github.com/shadcn-ui/ui)
- [daisy_ui_components structure and installer workflow](https://github.com/phcurado/daisy_ui_components)

## Goals

- Provide shadcn-style components with Phoenix-native ergonomics.
- Use Tailwind CSS tokens and class patterns compatible with modern shadcn conventions.
- Offer self-install tooling for host Phoenix projects.
- Support style/theme overrides with the same CSS-variable model used by shadcn.
- Ship Storybook stories for broad component preview coverage.

## Installation

### 1) Add dependency

```elixir
def deps do
  [
    {:extraordinary_ui, "~> 0.1.0"}
  ]
end
```

### 2) Fetch deps

```bash
mix deps.get
```

### 3) Install assets and JS hooks

```bash
mix extraordinary_ui.install
```

Installer behavior:

- Copies `assets/css/extraordinary_ui.css`
- Copies `assets/js/extraordinary_ui.js`
- Updates `assets/css/app.css` with:
  - `@source "../../deps/extraordinary_ui";`
  - `@import "./extraordinary_ui.css";`
- Updates `assets/js/app.js` to merge `ExtraordinaryUIHooks` into LiveView hooks
- Installs `tailwindcss-animate` in your assets package manager

Optional flags:

```bash
mix extraordinary_ui.install --assets-path assets --package-manager pnpm --style nova
```

Supported package managers: `npm`, `pnpm`, `yarn`, `bun`.

Supported style presets: `nova`, `maia`, `lyra`, `mira`, `vega`.

If you want to avoid overwriting generated Extraordinary UI files when re-running the installer:

```bash
mix extraordinary_ui.install --skip-existing
```

`--skip-existing` skips overwriting:

- `assets/css/extraordinary_ui.css`
- `assets/js/extraordinary_ui.js`
- `assets/css/.extraordinary_ui_style`

## Usage in `MyAppWeb`

```elixir
defp html_helpers do
  quote do
    use Phoenix.Component
    use ExtraordinaryUI
  end
end
```

You can also selectively import modules:

```elixir
import ExtraordinaryUI.Components.Actions
import ExtraordinaryUI.Components.Forms
```

## Theme and Style Overrides (shadcn model)

Extraordinary UI uses shadcn-style CSS variables (`--background`, `--foreground`, `--primary`, etc.) and dark mode with `.dark`.

### Override tokens globally

```css
:root {
  --primary: oklch(0.54 0.22 262);
  --radius: 0.75rem;
}

.dark {
  --primary: oklch(0.72 0.18 262);
}
```

### Use style presets

Preset radius profiles are included:

- `.style-maia`
- `.style-lyra`
- `.style-mira`
- `.style-nova`
- `.style-vega`

Apply one at app root:

```html
<html class="style-nova">
```

## Component Coverage

Legend:

- `Full`: production-ready server-rendered implementation
- `Progressive`: base implementation with optional LiveView hook enhancement
- `Scaffold`: layout + API contract for integration with external libs

| shadcn component family | Status |
| --- | --- |
| Accordion | Full |
| Alert | Full |
| Alert Dialog | Full |
| Aspect Ratio | Full |
| Avatar | Full |
| Badge | Full |
| Breadcrumb | Full |
| Button / Button Group | Full |
| Calendar | Scaffold |
| Carousel | Progressive |
| Chart | Scaffold |
| Checkbox | Full |
| Collapsible | Full |
| Combobox | Progressive |
| Command | Full |
| Context Menu | Not yet (JS-heavy menu semantics) |
| Dialog | Progressive |
| Drawer | Progressive |
| Dropdown Menu | Progressive |
| Empty | Full |
| Field / Form primitives | Full |
| Hover Card | Full |
| Input Group | Full |
| Input OTP | Full |
| Input | Full |
| Item | Full |
| Kbd | Full |
| Label | Full |
| Menubar | Progressive |
| Native Select | Full |
| Navigation Menu | Full |
| Pagination | Full |
| Popover | Progressive |
| Progress | Full |
| Radio Group | Full |
| Resizable | Scaffold |
| Scroll Area | Full |
| Select | Full (native select style) |
| Separator | Full |
| Sheet | Full (drawer alias) |
| Sidebar | Scaffold |
| Skeleton | Full |
| Slider | Full (native range) |
| Sonner | Scaffold (mount point) |
| Spinner | Full |
| Switch | Full |
| Table | Full |
| Tabs | Full |
| Textarea | Full |
| Toggle / Toggle Group | Full |
| Tooltip | Full |

## Storybook Preview

This project ships story files in `/storybook` and a helper module:

```elixir
defmodule MyAppWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :my_app,
    content_path: ExtraordinaryUI.Storybook.content_path(),
    css_path: "/assets/app.css",
    js_path: "/assets/app.js"
end
```

Bundled stories cover:

- Actions
- Forms
- Layout
- Feedback
- Data Display
- Navigation
- Overlay
- Advanced

## Static Docs Export

You can generate a fully static docs site (HTML/CSS/JS) without running Phoenix in production:

```bash
mix extraordinary_ui.docs.build
```

This writes a deployable site to:

- `dist/docs/index.html`
- `dist/docs/components/*.html`
- `dist/docs/assets/site.css`
- `dist/docs/assets/site.js`

Optional flags:

```bash
mix extraordinary_ui.docs.build --output public/docs --clean
```

The output can be hosted on any static platform (GitHub Pages, Netlify, S3, Cloudflare Pages, etc).

The generated site includes:

- an overview page plus one page per component (`dist/docs/components/...`)
- client-side interactivity for preview behaviors (dialogs, drawers, popovers, dropdowns, comboboxes, and carousel controls) without Phoenix running
- links to the corresponding shadcn/ui reference docs for each component
- generated attributes and slots docs derived from component `attr/slot` definitions (`__components__/0`)
- copyable HEEx usage snippets generated from sample assigns

It also includes shadcn-style theme controls:

- mode: `light` / `dark` / `auto`
- color palettes: `zinc`, `slate`, `stone`, `gray`, `neutral`
- radius profiles: `maia`, `mira`, `nova`, `lyra`, `vega`

## Developer/Marketing Static Site

Build a top-level static site that includes the docs export under `/docs`:

```bash
mix extraordinary_ui.site.build --clean
```

Output:

- `dist/site/index.html` (developer/marketing landing page)
- `dist/site/docs/**` (full static component library export)
- `dist/site/assets/site.css`

Optional flags:

```bash
mix extraordinary_ui.site.build \
  --output public \
  --clean \
  --github-url https://github.com/levi/extraordinaryui \
  --hexdocs-url https://hexdocs.pm/extraordinary_ui
```

This is fully static HTML/CSS/JS and can be deployed to GitHub Pages, Cloudflare Pages, Vercel, Netlify, S3, or any static host.

## Local Sandbox App

This repo includes a local Phoenix host app for integration testing:

- `/Users/levi/src/xmo/extraordinaryui/sandbox/demo_app`

The sandbox renders the full component catalog at:

- `http://localhost:4000/`

Alias route:

- `http://localhost:4000/components`

The sandbox catalog includes the same theme controls and copyable HEEx snippets as the static docs exporter.

Run it:

```bash
cd sandbox/demo_app
mix deps.get
mix extraordinary_ui.install --skip-existing
mix phx.server
```

## Browser Tests (Playwright)

Playwright tests run against the sandbox app and cover:

- full catalog rendering (every component card)
- sidebar navigation rendering
- Phoenix snippet panel availability
- interactive previews (dialog, drawer, popover, dropdown, combobox, carousel)
- theme controls (mode, color, radius)
- visual regression snapshots for every component card

Setup and run:

```bash
cd sandbox/demo_app
npm ci
npx playwright install --with-deps chromium
npx playwright test
```

CI-parity run (build assets first):

```bash
cd sandbox/demo_app
mix deps.get
mix assets.build
npx playwright test
```

Optional:

```bash
npx playwright test --headed
```

Visual snapshots:

```bash
cd sandbox/demo_app
npx playwright test tests/browser/visual.spec.ts
npx playwright test tests/browser/visual.spec.ts --update-snapshots
```

Snapshot baselines are stored at:

- `/Users/levi/src/xmo/extraordinaryui/sandbox/demo_app/tests/browser/visual.spec.ts-snapshots`

## JS Hooks

Hook implementations live in `assets/js/extraordinary_ui.js`:

- `EuiDialog`
- `EuiDrawer`
- `EuiPopover`
- `EuiDropdownMenu`
- `EuiCombobox`
- `EuiCarousel`

The installer automatically wires these into `assets/js/app.js`.

## API and Module Docs

Every component module includes in-source docs and usage examples:

- `ExtraordinaryUI.Components.Actions`
- `ExtraordinaryUI.Components.Forms`
- `ExtraordinaryUI.Components.Layout`
- `ExtraordinaryUI.Components.Feedback`
- `ExtraordinaryUI.Components.DataDisplay`
- `ExtraordinaryUI.Components.Navigation`
- `ExtraordinaryUI.Components.Overlay`
- `ExtraordinaryUI.Components.Advanced`

Generate docs:

```bash
mix docs
```

## Quality Gates

Implemented and verified with:

```bash
mix quality
MIX_ENV=test mix coveralls.cobertura --raise
mix extraordinary_ui.docs.build --output tmp/ci-docs --clean
mix extraordinary_ui.site.build --output tmp/ci-site --clean
cd sandbox/demo_app && mix format --check-formatted && mix test
cd sandbox/demo_app && npm ci && mix assets.build && npx playwright test
```

## GitHub Actions

Continuous integration is configured in:

- `.github/workflows/ci.yml`
- `.github/workflows/publish-site.yml`

Jobs included:

- Root quality checks (`mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix credo --strict`, static docs build)
- Root unit tests with coverage gate and Cobertura export (`MIX_ENV=test mix coveralls.cobertura --raise`)
- Sandbox Phoenix unit tests
- Sandbox Playwright browser tests (with Chromium install and failure artifact upload)
- Static developer site release deployment to GitHub Pages on `release.published`

Coverage is summarized directly in the GitHub Actions job summary and stored as an artifact (`root-coverage`).

### GitHub Pages Release Deployment

GitHub Pages hosting is feasible and already wired for this repo. The publish workflow:

- runs on GitHub release publish (`release.published`)
- builds `dist/site` using `mix extraordinary_ui.site.build --output dist/site --clean`
- deploys that artifact to GitHub Pages

One-time repo setup:

1. In GitHub repo settings, open **Pages**.
2. Set **Source** to **GitHub Actions**.
3. Publish a release to trigger deployment.

If you prefer Cloudflare Pages or Vercel, point their build output to `dist/site` and run `mix extraordinary_ui.site.build --output dist/site --clean` in their build command.

## Notes on Feasibility

A small set of shadcn components rely on browser-first interaction stacks (Radix primitives, complex keyboard navigation, chart engines, or heavy client state). For those, Extraordinary UI provides either:

- progressive LiveView hook behavior, or
- a scaffold component with stable API + styling that can be integrated with your preferred JS library.

This keeps the Elixir API coherent while avoiding brittle pseudo-ports of highly interactive React internals.

## License

MIT
