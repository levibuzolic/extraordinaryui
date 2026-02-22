# Extraordinary UI Progress

## Execution Plan

1. Bootstrap the library skeleton and quality gates.
2. Build core utilities (class composition, design tokens, and install templates).
3. Implement a broad shadcn-inspired component surface area with Phoenix function components.
4. Add Storybook coverage for component preview and interaction demos.
5. Implement installer automation for Tailwind dependencies, CSS tokens, and JS hooks.
6. Add tests and final documentation polish.

## Progress Log

- [x] Project skeleton created (`mix.exs`, formatting config, folder layout).
- [x] Core utility layer complete.
- [x] Component modules complete.
- [x] Storybook previews complete.
- [x] Static docs exporter complete.
- [x] Local Phoenix sandbox app complete.
- [x] Browser automation tests complete.
- [x] Installer task complete.
- [x] Tests complete.
- [x] README and release docs complete.

## Validation

- `mix format`
- `mix quality`
- `MIX_ENV=test mix coveralls.cobertura --raise`
- `cd sandbox/demo_app && mix format --check-formatted && mix test`
- `cd sandbox/demo_app && npm ci && mix assets.build && npx playwright test`

All validation checks currently pass.

## Milestones

### Milestone 1: Project bootstrap

- Created Mix project metadata and package scaffolding.
- Added base module entrypoints and utility helpers.

### Milestone 2: Component implementation

- Implemented shadcn-inspired component modules:
  - `Actions`
  - `Forms`
  - `Layout`
  - `Feedback`
  - `DataDisplay`
  - `Navigation`
  - `Overlay`
  - `Advanced`
- Added `data-slot` semantics and class patterns aligned with shadcn styles.

### Milestone 3: Installer and assets

- Added `mix extraordinary_ui.install`.
- Added Tailwind token stylesheet template and JS hooks template.
- Added hook module docs and generated install markers.

### Milestone 4: Storybook and tests

- Added Storybook root index and grouped component stories.
- Added component test suite (18 tests).
- Confirmed compile/test pipeline passes.

### Milestone 5: Static docs export

- Added static docs catalog that renders all public component functions.
- Added `mix extraordinary_ui.docs.build` to generate deployable `dist/docs` output.
- Added tests for catalog coverage and static build artifacts.

### Milestone 6: Sandbox host app and Playwright coverage

- Added a local Phoenix app at `sandbox/demo_app` embedding `extraordinary_ui` via local path dependency.
- Added `/components` catalog page in the sandbox host app for real browser validation.
- Added Playwright browser tests covering full component catalog rendering, sidebar navigation, and key interactions.
- Documented run/test/export workflows in root and sandbox READMEs.
- Added theme switchers (light/dark/auto + color palette + radius profile) to static docs and sandbox catalog.
- Replaced rendered-HTML copy snippets with generated Phoenix HEEx component snippets in docs cards.

### Milestone 7: CI and coverage automation

- Added GitHub Actions pipeline at `.github/workflows/ci.yml`.
- Added root quality gate job for formatting, strict credo, compile warnings-as-errors, and static docs export build.
- Added root unit test + coverage job with Cobertura report generation and coverage summary output.
- Added sandbox unit test job and sandbox browser test job with Playwright + Chromium.
- Added local commands in README docs to mirror CI exactly.

### Milestone 8: HEEx snippet composition quality

- Updated static docs snippet generation to support separate rendered-preview vs template-HEEx slot content.
- Rewrote nested examples to prefer Extraordinary UI components (`.button`, `.input`, `.table_*`, `.breadcrumb_*`, `.pagination_*`, etc.) over raw HTML where equivalent components exist.
- Kept plain HTML only where no suitable component abstraction exists.

### Milestone 9: Component-detail docs pages

- Upgraded static docs export to generate one page per component under `dist/docs/components/*.html`.
- Added shadcn/ui reference links per component entry with derived URL mapping and safe fallbacks.
- Added generated attributes and slots docs sourced from Phoenix component metadata (`__components__/0`) so docs stay aligned with `attr`/`slot` definitions.
- Kept the index page as an overview with links into each detailed component page.

## Commit Log

- `30d2a9c` - bootstrap Mix project, package metadata, and core module entrypoints.
- `b7c67ff` - implement shadcn-inspired component modules across major categories.
- `6a0d321` - add installer task, theme assets, JS hooks, and templates.
- `78dad14` - add Storybook indexes and category stories.
- `14ef672` - add component tests and extensive README/PROGRESS documentation.
- `5cd17a6` - document milestone commit log in progress tracker.
- `af013ff` - add `--skip-existing` installer option for generated files.
- `38675cb` - add static docs exporter for full component catalog.
- `c0a5e7d` - close overlay previews by default and add static docs interactions.
- `6a9181a` - expand installer/docs test coverage and wire ExCoveralls coverage tooling.
- `3ac6fa6` - add GitHub Actions CI for quality, coverage reporting, sandbox unit tests, and Playwright browser tests.
