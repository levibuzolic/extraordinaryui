# Demo Sandbox (`sandbox/demo_app`)

This Phoenix app embeds `extraordinary_ui` as a local path dependency to provide an end-to-end host environment for manual QA and browser automation.

## What it provides

- `GET /` - small landing page
- `GET /components` - full Extraordinary UI component catalog preview (all exported component entries)
- client-side interactions for overlay/component demos (dialog, drawer, popover, dropdown, combobox, carousel)

## Run the server

```bash
cd sandbox/demo_app
mix deps.get
mix extraordinary_ui.install --skip-existing
mix phx.server
```

Then open:

- [http://localhost:4000/components](http://localhost:4000/components)

## Run Elixir tests

```bash
cd sandbox/demo_app
mix test
```

## Run browser tests (Playwright)

```bash
cd sandbox/demo_app
npm install
npx playwright install chromium
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

## Export static docs site (from repo root)

```bash
cd /Users/levi/src/xmo/extraordinaryui
mix extraordinary_ui.docs.build --output dist/docs --clean
```

Output:

- `dist/docs/index.html`
- `dist/docs/assets/site.css`
- `dist/docs/assets/site.js`
