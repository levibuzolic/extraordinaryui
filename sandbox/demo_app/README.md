# Demo Sandbox (`sandbox/demo_app`)

This Phoenix app embeds `extraordinary_ui` as a local path dependency to provide an end-to-end host environment for manual QA and browser automation.

## What it provides

- `GET /` - full Extraordinary UI component catalog preview (default entry)
- `GET /components` - alias route for the same catalog view
- shadcn-style theme controls on the catalog page:
  - mode (`light`/`dark`/`auto`)
  - palette (`zinc`/`slate`/`stone`/`gray`/`neutral`)
  - radius (`maia`/`mira`/`nova`/`lyra`/`vega`)
- copyable component snippets as Phoenix template tags (`Copy HEEx`)
- client-side interactions for overlay/component demos (dialog, drawer, popover, dropdown, combobox, carousel)

## Run the server

```bash
cd sandbox/demo_app
mix deps.get
mix extraordinary_ui.install --skip-existing
mix phx.server
```

Then open:

- [http://localhost:4000/](http://localhost:4000/)

## Run Elixir tests

```bash
cd sandbox/demo_app
mix format --check-formatted
mix test
```

## Run browser tests (Playwright)

```bash
cd sandbox/demo_app
mix deps.get
mix assets.build
npm ci
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

- `/Users/levi/src/xmo/extraordinaryui/.github/workflows/ci.yml`

## Export static docs site (from repo root)

```bash
cd /Users/levi/src/xmo/extraordinaryui
mix extraordinary_ui.docs.build --output dist/docs --clean
```

Output:

- `dist/docs/index.html`
- `dist/docs/components/*.html`
- `dist/docs/assets/site.css`
- `dist/docs/assets/site.js`
