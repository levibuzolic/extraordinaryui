# Demo Sandbox (`sandbox/demo_app`)

This Phoenix app embeds `cinder_ui` as a local path dependency to provide an end-to-end host environment for manual QA and browser automation.

## What it provides

- `GET /` - full Cinder UI component catalog preview (default entry)
- `GET /docs` - live alias route for the same component catalog view (dev-server runtime)
- shadcn-style theme controls on the catalog page:
  - mode (`light`/`dark`/`auto`)
  - palette (`zinc`/`slate`/`stone`/`gray`/`neutral`)
  - radius presets with explicit sizes (`Compact 6px`, `Small 8px`, `Default 12px`, `Large 14px`, `XL 16px`)
- copyable component snippets as Phoenix template tags (`Copy HEEx`)
- client-side interactions for overlay/component demos (dialog, drawer, popover, dropdown, combobox, carousel)

## Run the server

```bash
cd sandbox/demo_app
mix deps.get
mix cinder_ui.install --skip-existing
mix phx.server
```

Then open:

- [http://localhost:4000/](http://localhost:4000/)
- [http://localhost:4000/docs](http://localhost:4000/docs)

## Run Elixir tests

```bash
cd sandbox/demo_app
mix format --check-formatted
mix credo --strict
mix test
```

## Run browser tests (Playwright)

```bash
cd sandbox/demo_app
mix deps.get
npm ci
mix assets.build
npx playwright install --with-deps chromium
npx playwright test
```

Headed mode:

```bash
npx playwright test --headed
```

Playwright config:

- `sandbox/demo_app/playwright.config.ts`
- `sandbox/demo_app/tests/browser/components.spec.ts`
- `sandbox/demo_app/tests/browser/interactions.spec.ts`
- `sandbox/demo_app/tests/browser/visual.spec.ts`

Visual regression snapshots:

```bash
cd sandbox/demo_app
npx playwright test tests/browser/visual.spec.ts
```

Update visual baselines after intentional UI changes:

```bash
cd sandbox/demo_app
npx playwright test tests/browser/visual.spec.ts --update-snapshots
```

Snapshot baseline folder:

- `sandbox/demo_app/tests/browser/visual.spec.ts-snapshots`

## CI

GitHub Actions run this sandbox in two jobs:

- `Sandbox Unit Tests`: formatting + `mix test`
- `Sandbox Browser Tests (Playwright)`: asset build + Chromium install + `npx playwright test`

Workflow file:

- `.github/workflows/ci.yml`

## Export static docs site (from repo root)

```bash
cd ../..
mix cinder_ui.docs.build
```

Output:

- `dist/site/index.html` (marketing home page)
- `dist/site/docs/index.html` (component docs index)
- `dist/site/docs/components/*.html`
- `dist/site/docs/assets/site.css`
- `dist/site/docs/assets/site.js`
