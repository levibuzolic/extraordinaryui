# Cinder UI

Shadcn-inspired UI components for Phoenix + LiveView.

Cinder UI is a Hex-oriented component library that ports shadcn/ui design patterns, classes, tokens, and compositional structure into Elixir function components.

## Installation

### 1) Add dependency

```elixir
def deps do
  [
    {:cinder_ui, "~> 0.1.0"},
    # optional but recommended for <.icon /> and icon-based primitives
    {:lucide_icons, "~> 2.0"}
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
mix cinder_ui.install --assets-path assets --package-manager pnpm
```

Supported package managers: `npm`, `pnpm`, `yarn`, `bun`.

If you want to avoid overwriting generated files when re-running the installer:

```bash
mix cinder_ui.install --skip-existing
```

`--skip-existing` skips overwriting:

- `assets/css/cinder_ui.css`
- `assets/js/cinder_ui.js`

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

## Icons (Optional, Recommended)

`CinderUI.Icons.icon/1` dispatches to [`lucide_icons`](https://hex.pm/packages/lucide_icons).

- Cinder UI reads `lucide_icons.icon_names/0` and caches names automatically.
- Both kebab-case and snake_case icon names are supported.

Example:

```heex
<.icon name="chevron-down" class="size-4" />
<.icon name="loader_circle" class="size-4 animate-spin" />
```

If `lucide_icons` is missing and `<.icon />` is used, Cinder UI raises an error.

## Theming and Style Overrides

Cinder UI uses shadcn-style CSS variables (`--background`, `--foreground`, `--primary`, etc.) and dark mode with `.dark`.

### Configure variables (shadcn-style)

```css
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.54 0.22 262);
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
  --primary: oklch(0.72 0.18 262);
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
```

Set your preferred corner scale by changing `--radius`; component classes (`rounded-md`, `rounded-lg`, etc.) derive from that value through the Tailwind token mapping in `assets/css/cinder_ui.css`.

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
| Icons (`CinderUI.Icons.icon/1`) | ✅ Full | Server-rendered | Requires optional `lucide_icons` dependency |
| Item | ✅ Full | Server-rendered | - |
| Kbd | ✅ Full | Server-rendered | - |
| Label | ✅ Full | Server-rendered | - |
| Menubar | ⚡ Progressive | Server + hooks | Hook layer handles interactive menu behavior |
| Menu | ✅ Full | Server-rendered | daisyUI-inspired navigation list primitive |
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
| Toast | ✅ Full | Server-rendered | Presentational toast container/items for app-level notifications |
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

## API Docs

Every component module includes in-source docs and usage examples. Generate docs with:

```bash
mix docs
```

## Feasibility Notes

A subset of shadcn components rely on browser-first stacks (Radix primitives, complex keyboard navigation, chart engines, or heavy client state). For these, Cinder UI provides either progressive LiveView hook behavior or a scaffold component with stable API + styling.

## Attribution and Third-Party Notices

Cinder UI is built on the shoulders of giants, leveraging the awesome work from these projects:

- [shadcn/ui](https://ui.shadcn.com/docs) ([GitHub](https://github.com/shadcn-ui/ui))
- [Tailwind CSS](https://tailwindcss.com/) ([GitHub](https://github.com/tailwindlabs/tailwindcss))
- [tailwindcss-animate](https://github.com/jamiebuilds/tailwindcss-animate)
- [lucide_icons](https://hex.pm/packages/lucide_icons) ([GitHub](https://github.com/zoedsoupe/lucide_icons))
- [Lucide Icons](https://lucide.dev/icons/)

Thank you to the maintainers and contributors.

For third-party license details and links to upstream license texts, see: [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for contributor setup, quality gates, testing, release workflow, and docs/site build maintenance.

## License

MIT
