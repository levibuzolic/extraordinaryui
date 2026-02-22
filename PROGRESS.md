# Extraordinary UI Progress

## Current Plan (February 22, 2026)

1. Keep CI quality, coverage, docs export, static site export, and browser regression green for every change.
2. Publish first Hex package + HexDocs and verify release documentation flow.
3. Continue closing shadcn parity gaps in JS-heavy/scaffold components while preserving Phoenix-first APIs.

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
- `mix extraordinary_ui.site.build --output tmp/verify-site --clean`
- `cd sandbox/demo_app && mix format --check-formatted && mix test`
- `cd sandbox/demo_app && npm ci && mix assets.build && npx playwright test`

All validation checks currently pass (last run: February 22, 2026).

## Remaining Work

- [ ] Publish Hex package and HexDocs for `extraordinary_ui`.
- [ ] Add release automation for Hex publish (requires repository secrets and release gating decisions).
- [ ] Implement `Context Menu` or formally document it as out-of-scope.
- [ ] Deepen scaffold/progressive parity for `Calendar`, `Chart`, `Resizable`, `Sidebar`, and `Sonner`.
- [ ] Expand browser tests for keyboard/focus accessibility behavior in progressive overlay/menu components.

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
- Added embedded base64 sample avatars in avatar and avatar-group docs previews (and snippets) for production-like visual fidelity.

### Milestone 10: Browser visual regression suite

- Added Playwright visual regression test `sandbox/demo_app/tests/browser/visual.spec.ts` capturing screenshots for every component card.
- Added committed snapshot baselines in `sandbox/demo_app/tests/browser/visual.spec.ts-snapshots`.
- Added npm scripts to run/update visual baselines:
  - `npm run test:browser:visual`
  - `npm run test:browser:visual:update`

### Milestone 11: Static developer site + release publishing

- Added `mix extraordinary_ui.site.build` to generate a static developer/marketing landing page and bundle static component docs under `dist/site/docs`.
- Added test coverage for site build output and links in `test/extraordinary_ui/site/build_task_test.exs`.
- Added CI validation step that builds the static developer site artifact during root quality checks.
- Added GitHub Pages publish workflow (`.github/workflows/publish-site.yml`) triggered on `release.published` and manual dispatch.
- Updated README with commands and one-time GitHub Pages setup steps, plus Cloudflare/Vercel fallback deployment guidance.

### Milestone 12: Documentation reality pass

- Audited root and sandbox documentation against actual routes, workflows, and commands.
- Replaced machine-specific absolute paths with repository-relative paths in docs.
- Added explicit current-status and release-checklist guidance, including manual Hex publish status.
- Added remaining-work tracking so incomplete items are clearly visible.
- Upgraded README component-coverage matrix to use emoji status markers and split compatibility into coverage/interactivity/limitations columns.
- Fixed static component-page function docs rendering to parse markdown (headings/lists/code) instead of escaped plaintext blocks.
- Added markdown presentation styles for docs content and tests asserting markdown-rendered output.
- Added inline-backtick rendering for non-markdown docs text (e.g., summaries/headings) using styled `<code>` spans across static docs pages.
- Added consistent sidebar active-state treatment in static docs (`Overview` on index, current component on detail pages) with `aria-current="page"` and clear active styling.
- Added `Copy HEEx` actions to overview cards on the root static docs page so snippets can be copied without opening per-component pages.
- Added always-visible HEEx snippet code boxes to overview cards (no expand/collapse toggle required) while retaining quick copy actions.
- Fixed duplicate disclosure arrows in previewed collapsible/accordion components by scoping docs-shell summary pseudo-arrows away from component `summary[data-slot]` elements.
- Aligned `Forms.select/1` + `native_select/1` markup/classes with current shadcn v4 native-select pattern (`appearance-none`, `pr-9`, wrapper, and right-aligned chevron icon spacing).

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
- `e9e84bc` - add static developer site build task, tests, CI checks, and GitHub Pages release deployment workflow.
- `e6f9866` - run documentation reality pass, add remaining-work tracker, and add root AGENTS guide for future development.
- `bfeb4d4` - refine README shadcn coverage matrix with emoji status + compatibility breakdown columns.
- `87a9ab1` - render function docs markdown in static docs and style markdown output blocks.
- `7313113` - render inline backtick segments as styled code spans throughout static docs shell text.
- `eaf9eca` - add consistent active indicator for sidebar Overview and current component links in static docs.
- `f50ad56` - add overview-card `Copy HEEx` actions on root static docs page.
- `89d6aef` - make overview-card HEEx snippets always expanded in root static docs.
- `733e521` - fix duplicated disclosure arrows by refining summary marker CSS in static docs shell.
- `pending` - align native select arrow spacing with upstream shadcn v4 implementation.
