# Cinder UI Progress

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
- [x] Rich multi-example docs pass complete.

## Validation

- `mix format`
- `mix quality`
- `mix credo --strict`
- `MIX_ENV=test mix coveralls.cobertura --raise`
- `mix cinder_ui.docs.build --output tmp/ci-docs --clean`
- `mix cinder_ui.site.build --output tmp/ci-site --clean`
- `cd sandbox/demo_app && mix format --check-formatted && mix test`
- `cd sandbox/demo_app && npm ci && mix assets.build && npx playwright test`

All validation checks currently pass (last run: February 22, 2026, including Lucide icon integration and updated visual baselines).

## Remaining Work

- [ ] Publish Hex package and HexDocs for `cinder_ui`.
- [ ] Implement `Context Menu` or formally document it as out-of-scope.
- [ ] Deepen scaffold/progressive parity for `Calendar`, `Chart`, `Resizable`, `Sidebar`, and `Sonner`.
- [ ] Expand browser tests for keyboard/focus accessibility behavior in progressive overlay/menu components.
- [ ] Daisy gap phase 2: evaluate/implement `steps`, `timeline`, and toast orchestration hooks after validating phase 1 adoption feedback.

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

- Added `mix cinder_ui.install`.
- Added Tailwind token stylesheet template and JS hooks template.
- Added hook module docs and generated install markers.

### Milestone 4: Storybook and tests

- Added Storybook root index and grouped component stories.
- Added component test suite (18 tests).
- Confirmed compile/test pipeline passes.

### Milestone 5: Static docs export

- Added static docs catalog that renders all public component functions.
- Added `mix cinder_ui.docs.build` to generate deployable `dist/docs` output.
- Added tests for catalog coverage and static build artifacts.

### Milestone 6: Sandbox host app and Playwright coverage

- Added a local Phoenix app at `sandbox/demo_app` embedding `cinder_ui` via local path dependency.
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
- Added repository-level Credo config at `.credo.exs` for explicit lint scope and CI parity.

### Milestone 8: HEEx snippet composition quality

- Updated static docs snippet generation to support separate rendered-preview vs template-HEEx slot content.
- Rewrote nested examples to prefer Cinder UI components (`.button`, `.input`, `.table_*`, `.breadcrumb_*`, `.pagination_*`, etc.) over raw HTML where equivalent components exist.
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
- Hardened visual snapshots against cross-environment 1px card-height drift by targeting per-component preview containers and normalizing preview capture height in test CSS.

### Milestone 11: Static developer site + release publishing

- Added `mix cinder_ui.site.build` to generate a static developer/marketing landing page and bundle static component docs under `dist/site/docs`.
- Added test coverage for site build output and links in `test/cinder_ui/site/build_task_test.exs`.
- Added CI validation step that builds the static developer site artifact during root quality checks.
- Added GitHub Pages publish workflow (`.github/workflows/publish-site.yml`) triggered on `release.published` and manual dispatch.
- Updated README with commands and one-time GitHub Pages setup steps, plus Cloudflare/Vercel fallback deployment guidance.

### Milestone 12: Documentation reality pass

- Audited root and sandbox documentation against actual routes, workflows, and commands.
- Replaced machine-specific absolute paths with repository-relative paths in docs.
- Added explicit current-status and release-checklist guidance, including Hex publish status and next steps.
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
- Fixed `Forms.switch/1` to fully suppress native checkbox glyph rendering (`appearance-none`) and use dynamic `checked`/`peer-checked` state classes for track/thumb behavior.
- Added support for multiple generated examples per component in detailed docs pages.
- Added support for multiple inline-doc examples by extracting fenced and indented HEEx snippets from function `@doc` text.
- Upgraded `Layout.card/1` examples to richer shadcn-style compositions (header/content/footer/actions), including multiple complete variants.
- Expanded `DataDisplay.table/1` and `Navigation.pagination/1` samples to more complete, shadcn-style compositions (caption/footer and prev/next/ellipsis flows).

### Milestone 13: Rich example parity and inline-doc labeling

- Expanded richer multi-example coverage beyond `card` to additional core families:
  - `Actions.button/1`
  - `Forms.field/1`
  - `Feedback.alert/1`
  - `DataDisplay.accordion/1`
  - `Navigation.tabs/1`
  - `Overlay.dialog/1`
  - `Advanced.command/1`
- Upgraded nested sample previews to use Cinder UI components where feasible (`button_group`, `toggle_group`, `field`, `input_group`, `empty_state`, overlay footers, tooltip trigger, command items, menubar content).
- Added inline-doc fenced example metadata parsing (`title="..."` and `title='...'`) so detailed docs pages can render multiple named examples from `@doc` content.
- Added docs and tests validating titled inline examples and multi-example coverage expectations.

### Milestone 14: Audience-focused docs split and licensing notices

- Split contributor/maintainer workflow content out of `README.md` into new `CONTRIBUTING.md`.
- Refocused `README.md` on application-consumer install/usage/theming/docs guidance.
- Added `THIRD_PARTY_NOTICES.md` with licensing links and acknowledgements for:
  - shadcn/ui
  - Tailwind CSS
  - tailwindcss-animate
- Added package/docs metadata entries so `CONTRIBUTING.md` and `THIRD_PARTY_NOTICES.md` ship with Hex package docs context.
- Updated `AGENTS.md` documentation requirements to preserve the README vs CONTRIBUTING audience split.

### Milestone 15: Marketing site component-native refresh

- Rebuilt the static marketing landing page to render using Cinder UI component functions instead of custom ad-hoc HTML controls.
- Set marketing site baseline to the neutral token palette with `style-nova` radius profile and Tailwind v4 browser styling.
- Added a persistent dark/light mode toggle to the static marketing site (`localStorage` + `.dark` root class) with active-state UI controls in the header.
- Added a homepage examples section with live previews/snippets for:
  - `Actions.button_group`
  - `Forms.field`
  - `Feedback.alert`
  - `Navigation.tabs`
- Added per-example links back to the corresponding shadcn/ui docs and ensured shadcn mentions in marketing copy link to upstream docs.
- Expanded site build test assertions to cover component examples, neutral style marker, and shadcn reference links.

### Milestone 16: Automated Hex release publishing

- Added GitHub Actions Hex publish workflow (`.github/workflows/publish-hex.yml`) triggered on `release.published` and manual dispatch.
- Wired package and docs publication to `HEX_API_KEY` secret and added explicit failure messaging when the secret is missing.
- Added `hex-publish` environment targeting in the workflow to support release gating via GitHub environment protection.
- Updated maintainer release instructions in `CONTRIBUTING.md` with one-time secret setup and automated release flow.

### Milestone 17: Project rename to Cinder UI

- Renamed project identity from Extraordinary UI to Cinder UI across:
  - app/package identifiers (`:cinder_ui`, `CinderUI`)
  - file paths and module namespaces (`lib/cinder_ui/**`, `test/cinder_ui/**`)
  - Mix task names (`mix cinder_ui.install`, `mix cinder_ui.docs.build`, `mix cinder_ui.site.build`)
  - installer asset/template filenames (`cinder_ui.css`, `cinder_ui.js`, `.cinder_ui_style`)
  - sandbox dependency integration and docs references.
- Updated GitHub Actions workflows and contributor commands to use renamed Mix tasks.
- Refreshed browser visual baselines impacted by text and branding changes.
- Verified root quality, coverage gate, sandbox unit tests, and sandbox browser tests after rename.

### Milestone 18: Static docs naming and navigation polish

- Updated static docs component card titles to omit Elixir arity suffixes (for example `Forms.field` instead of `Forms.field/1`).
- Made static docs overview card titles link directly to each component detail docs page.
- Kept component example icon markup aligned with the existing SVG-based approach in docs/site previews.

### Milestone 19: Optional Lucide icon integration

- Added `CinderUI.Icons.icon/1` as an optional `lucide_icons` adapter with:
  - descriptive missing-dependency errors
  - unknown-icon suggestions
  - kebab-case and snake_case name support
  - cached icon-name lookup sourced from `lucide_icons.icon_names/0` (no sync task needed)
- Added optional root dependency metadata for `lucide_icons` and included `CinderUI.Icons` in generated docs module grouping.
- Migrated internal icon usage from inline SVG/Heroicons patterns to `CinderUI.Icons.icon/1` where appropriate (`Actions`, `Forms`, `Feedback`, docs/site samples, sandbox components).
- Added an `Icons` section in static docs catalog and corresponding catalog/unit tests.
- Added sandbox `lucide_icons` dependency and removed stale Heroicons dependency + vendor script.
- Updated README/CONTRIBUTING/third-party notices for the optional icon backend and licensing attribution.
- Updated Playwright visual baselines to include the new `Icons.icon` component card.

### Milestone 20: Continuous marketing-site deployment

- Updated `.github/workflows/publish-site.yml` to deploy GitHub Pages on every push to `main` (in addition to release/manual triggers).
- Updated contributor release/deploy documentation to reflect continuous site deployment behavior.
- Refined marketing-site copy to focus on end-user Phoenix/LiveView adoption benefits (Phoenix-native API, fast integration, shadcn-aligned styles) and removed static-docs-export framing from feature messaging.
- Clarified marketing install section by splitting `mix.exs` dependency edits from terminal commands (`mix deps.get` + installer), including explicit optional `lucide_icons` guidance.

### Milestone 21: Input/docs parity and daisy gap phase 1

- Aligned `Forms.input_group/1` with shadcn grouped-control behavior (single shell border, flattened child borders/shadows, unified focus ring).
- Updated `input_group` docs examples to match the refined structure (`outline` action button).
- Replaced static docs sidebar theme `<select>` markup with library-native `Forms.native_select/1` rendering so dropdown controls match package styles/classes.
- Added lightweight syntax highlighting for HEEx code snippets in both static docs and marketing site outputs (no additional runtime dependency).
- Completed a daisyUI/Phoenix gap pass against `phcurado/daisy_ui_components` and identified high-value additions.
- Executed phase 1 additions:
  - `Navigation.menu/1` (daisy-inspired menu primitive)
  - `Feedback.toast/1` + `Feedback.toast_item/1` (presentational toast primitives)
- Added catalog samples, slug mappings, and component tests for the new primitives.

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
- `98cc56e` - align native select arrow spacing with upstream shadcn v4 implementation.
- `13bfd58` - fix switch preview rendering so native checkbox glyph is not visible.
- `1335d6d` - add multi-example detailed docs rendering and richer card-aligned sample implementations.
- `a73a333` - expand table/pagination sample compositions for closer shadcn-style completeness.
- `d003fdc` - expand rich multi-family component samples and add named inline-doc example extraction.
- `7dda7aa` - stabilize Playwright visual snapshots by capturing normalized preview containers to avoid 1px cross-env card drift failures.
- `22e2293` - log visual snapshot stability hardening in the progress tracker.
- `c487941` - rename package/modules/tasks/assets/docs from Extraordinary UI to Cinder UI (`cinder_ui`/`CinderUI`) across the repository.
- `e9634c4` - split user-facing README from contributor docs and add third-party notices.
- `93b6ad4` - log documentation audience split and licensing notices.
- `8a82db2` - rebuild static marketing site landing page with component-native examples and shadcn reference linking.
- `(working tree)` - add automated Hex publish workflow, release secret setup docs, and progress tracking updates.
- `cc6c4f1` - add optional `lucide_icons` integration via `CinderUI.Icons`, migrate examples/sandbox icons, and update docs/tests/licenses.
- `(working tree)` - enable automatic GitHub Pages site publish on every `main` push and document workflow behavior.
- `(working tree)` - retarget marketing-site messaging to existing Phoenix/LiveView app benefits and update site assertions.
- `(working tree)` - clarify homepage install docs with separate `mix.exs` and terminal command blocks.
- `(working tree)` - align input_group and docs theme dropdown controls with library/upstream styles.
- `(working tree)` - add lightweight HEEx syntax highlighting to docs/site and implement daisy-gap phase 1 primitives (`menu`, `toast`).
