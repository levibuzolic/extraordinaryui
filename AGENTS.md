# AGENTS Guide

Contributor guide for `cinder_ui`.

## Scope

- Phoenix + LiveView component library ported from shadcn/ui patterns.
- Primary outputs:
  - Hex package: `cinder_ui`
  - Static site export: `dist/site`
  - Demo app for integration and browser tests: `demo`

## Code Map

- Library components: `lib/cinder_ui/**`
- Public installer task: `lib/mix/tasks/cinder_ui.install.ex`
- Static docs/site build task: `dev/lib/mix/tasks/cinder_ui.docs.build.ex`
- Marketing/static site composition: `dev/lib/cinder_ui/site/marketing.ex`
- Static docs catalog: `dev/lib/cinder_ui/docs/catalog.ex`
- Demo host app: `demo`

## Required Commands

Run from repository root unless noted.

- Root quality:
  - `mix quality`
  - `MIX_ENV=test mix coveralls.cobertura --raise` (writes `cover/cobertura.xml`)
- Static docs/site build:
  - `mix cinder_ui.docs.build`
- Demo unit checks:
  - `cd demo && mix format --check-formatted && mix test`
- Demo browser checks:
  - `cd demo && npm ci && mix assets.build && npx playwright test`

## Standards

- Keep APIs Phoenix-first: HEEx function components, predictable assigns, typed `attr`/`slot`.
- Prefer composing with existing components in docs/examples; use raw HTML only when necessary.
- Keep static docs and demo behavior aligned (theme controls, snippets, interactions).
- Use repository-relative paths in docs.
- Update tests whenever component behavior, docs generation, or JS hooks change.

## Documentation Rules

- `README.md`: user-facing install and usage guidance.
- `CONTRIBUTING.md`: contributor workflow and maintenance guidance.
- Update `README.md` and `CONTRIBUTING.md` when changes impact their audiences.
- Public component changes should include in-module docs and examples.

## Release Checklist

1. Bump version in `mix.exs` and update `CHANGELOG.md`.
2. Run all required quality, coverage, docs, and demo checks.
3. Publish package/docs to Hex (manual).
4. Publish GitHub release (triggers Pages deploy via `.github/workflows/publish-site.yml`).
