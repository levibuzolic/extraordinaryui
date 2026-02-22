# Cinder UI

Shadcn-inspired UI components for Phoenix + LiveView.

Cinder UI is a Hex-oriented component library that ports shadcn/ui design patterns, classes, tokens, and compositional structure into Elixir function components.

## Installation

### 1) Add dependency

```elixir
def deps do
  [
    {:cinder_ui, "~> 0.1.0"}
  ]
end
```

### 2) Fetch deps

```bash
mix deps.get
```

### 3) Install assets and hooks

```bash
mix cinder_ui.install
```

Installer behavior:

- Copies `assets/css/cinder_ui.css`
- Copies `assets/js/cinder_ui.js`
- Updates `assets/css/app.css` with:
  - `@source "../../deps/cinder_ui";`
  - `@import "./cinder_ui.css";`
- Updates `assets/js/app.js` to merge `CinderUIHooks` into LiveView hooks
- Installs `tailwindcss-animate` in your assets package manager

Optional flags:

```bash
mix cinder_ui.install --assets-path assets --package-manager pnpm --style nova
```

Supported package managers: `npm`, `pnpm`, `yarn`, `bun`.

Supported style presets: `nova`, `maia`, `lyra`, `mira`, `vega`.

If you want to avoid overwriting generated files when re-running the installer:

```bash
mix cinder_ui.install --skip-existing
```

`--skip-existing` skips overwriting:

- `assets/css/cinder_ui.css`
- `assets/js/cinder_ui.js`
- `assets/css/.cinder_ui_style`

## Usage in `MyAppWeb`

```elixir
defp html_helpers do
  quote do
    use Phoenix.Component
    use CinderUI
  end
end
```

You can also selectively import modules:

```elixir
import CinderUI.Components.Actions
import CinderUI.Components.Forms
```

## Theming and Style Overrides

Cinder UI uses shadcn-style CSS variables (`--background`, `--foreground`, `--primary`, etc.) and dark mode with `.dark`.

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

- `✅ Full`: production-ready server-rendered implementation
- `⚡ Progressive`: server-rendered base with optional LiveView hook enhancement
- `🧱 Scaffold`: layout + API contract ready; full behavior needs host-side JS integration
- `🚧 Not Yet`: intentionally not implemented yet

| shadcn component family | Coverage | Interactivity model | Compatibility / limitations |
| --- | --- | --- | --- |
| Accordion | ✅ Full | Server-rendered | Matches core usage patterns |
| Alert | ✅ Full | Server-rendered | - |
| Alert Dialog | ✅ Full | Server-rendered | - |
| Aspect Ratio | ✅ Full | Server-rendered | - |
| Avatar | ✅ Full | Server-rendered | - |
| Badge | ✅ Full | Server-rendered | - |
| Breadcrumb | ✅ Full | Server-rendered | - |
| Button / Button Group | ✅ Full | Server-rendered | - |
| Calendar | 🧱 Scaffold | Static shell | Full date-picker behavior requires additional JS |
| Carousel | ⚡ Progressive | Server + hooks | Hook layer drives controls/slide state |
| Chart | 🧱 Scaffold | Static shell | Requires external chart engine integration |
| Checkbox | ✅ Full | Server-rendered | - |
| Collapsible | ✅ Full | Server-rendered | - |
| Combobox | ⚡ Progressive | Server + hooks | Hook layer handles filtering/select behavior |
| Command | ✅ Full | Server-rendered | - |
| Context Menu | 🚧 Not Yet | N/A | JS-heavy semantics still pending |
| Dialog | ⚡ Progressive | Server + hooks | Hook layer handles open/close behavior |
| Drawer | ⚡ Progressive | Server + hooks | Hook layer handles panel/overlay behavior |
| Dropdown Menu | ⚡ Progressive | Server + hooks | Hook layer handles menu toggling |
| Empty | ✅ Full | Server-rendered | - |
| Field / Form primitives | ✅ Full | Server-rendered | - |
| Hover Card | ✅ Full | Server-rendered | - |
| Input Group | ✅ Full | Server-rendered | - |
| Input OTP | ✅ Full | Server-rendered | - |
| Input | ✅ Full | Server-rendered | - |
| Item | ✅ Full | Server-rendered | - |
| Kbd | ✅ Full | Server-rendered | - |
| Label | ✅ Full | Server-rendered | - |
| Menubar | ⚡ Progressive | Server + hooks | Hook layer handles interactive menu behavior |
| Native Select | ✅ Full | Server-rendered | Native HTML select with shadcn-style classes |
| Navigation Menu | ✅ Full | Server-rendered | - |
| Pagination | ✅ Full | Server-rendered | - |
| Popover | ⚡ Progressive | Server + hooks | Hook layer handles open/close behavior |
| Progress | ✅ Full | Server-rendered | - |
| Radio Group | ✅ Full | Server-rendered | - |
| Resizable | 🧱 Scaffold | Static shell | Drag/resize behavior needs additional JS |
| Scroll Area | ✅ Full | Server-rendered | - |
| Select | ✅ Full | Server-rendered | Implemented as native select style variant |
| Separator | ✅ Full | Server-rendered | - |
| Sheet | ✅ Full | Server-rendered | Drawer alias semantics |
| Sidebar | 🧱 Scaffold | Static shell | Complex interactions require host-side logic |
| Skeleton | ✅ Full | Server-rendered | - |
| Slider | ✅ Full | Server-rendered | Native range input style |
| Sonner | 🧱 Scaffold | Static shell | Mount point API; toast engine not bundled |
| Spinner | ✅ Full | Server-rendered | - |
| Switch | ✅ Full | Server-rendered | - |
| Table | ✅ Full | Server-rendered | - |
| Tabs | ✅ Full | Server-rendered | - |
| Textarea | ✅ Full | Server-rendered | - |
| Toggle / Toggle Group | ✅ Full | Server-rendered | - |
| Tooltip | ✅ Full | Server-rendered | - |

## Storybook Preview

This project ships story files in `/storybook` and a helper module:

```elixir
defmodule MyAppWeb.Storybook do
  use PhoenixStorybook,
    otp_app: :my_app,
    content_path: CinderUI.Storybook.content_path(),
    css_path: "/assets/app.css",
    js_path: "/assets/app.js"
end
```

## Static Docs Export

Generate a fully static docs site (HTML/CSS/JS) without Phoenix running in production:

```bash
mix cinder_ui.docs.build
```

Output:

- `dist/docs/index.html`
- `dist/docs/components/*.html`
- `dist/docs/assets/site.css`
- `dist/docs/assets/site.js`

Optional flags:

```bash
mix cinder_ui.docs.build --output public/docs --clean
```

The generated site includes:

- overview page plus one page per component
- interactive static previews for supported components
- links to the corresponding shadcn/ui docs
- generated attributes and slots docs from `attr/slot` definitions
- copyable HEEx usage snippets
- light/dark/auto + color + radius theme controls

## API Docs

Every component module includes in-source docs and usage examples. Generate docs with:

```bash
mix docs
```

## Feasibility Notes

A subset of shadcn components rely on browser-first stacks (Radix primitives, complex keyboard navigation, chart engines, or heavy client state). For these, Cinder UI provides either progressive LiveView hook behavior or a scaffold component with stable API + styling.

## Attribution and Third-Party Notices

Cinder UI is deeply inspired by and interoperates with the work from these projects:

- [shadcn/ui](https://ui.shadcn.com/docs) ([GitHub](https://github.com/shadcn-ui/ui))
- [Tailwind CSS](https://tailwindcss.com/) ([GitHub](https://github.com/tailwindlabs/tailwindcss))
- [tailwindcss-animate](https://github.com/jamiebuilds/tailwindcss-animate)

Thank you to the maintainers and contributors of these excellent projects.

For third-party license details and links to upstream license texts, see:

- [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)

## Contributing

Contributor setup, quality gates, testing, release workflow, and docs maintenance live in:

- [`CONTRIBUTING.md`](CONTRIBUTING.md)

Release publishing is automated via GitHub Actions for maintainers; see `CONTRIBUTING.md` for the one-time `HEX_API_KEY` secret setup.

## License

MIT
