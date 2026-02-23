# AGENTS Guide

Concise contributor guide for `cinder_ui`.

## Scope

- This repo is a Phoenix component library inspired by shadcn/ui.
- Primary outputs:
  - Hex package (`cinder_ui`)
  - Unified static docs/site output (`dist/site`)
  - Sandbox host app for integration/browser tests (`sandbox/demo_app`)

## Architecture

- Library code: `lib/cinder_ui/**`
- Public install task: `lib/mix/tasks/cinder_ui.install.ex`
- Internal docs/site tasks:
  - `dev/lib/mix/tasks/cinder_ui.docs.build.ex`
  - `dev/lib/cinder_ui/site/marketing.ex`
- Static docs catalog source: `dev/lib/cinder_ui/docs/catalog.ex`
- Sandbox app: `sandbox/demo_app`

## Core Commands

- Root quality:
  - `mix quality`
  - `MIX_ENV=test mix coveralls.cobertura --raise`
- Static outputs:
  - `mix cinder_ui.docs.build`
- Sandbox checks:
  - `cd sandbox/demo_app && mix format --check-formatted && mix test`
  - `cd sandbox/demo_app && npm ci && mix assets.build && npx playwright test`

## Engineering Standards

- Keep APIs Phoenix-first (HEEx function components, predictable assigns, typed `attr`/`slot` docs).
- Prefer component composition in docs/snippets; use raw HTML only when no library primitive exists.
- Keep static docs and sandbox behavior aligned (theme controls, snippets, interactions).
- Avoid machine-specific paths in docs; use repository-relative paths.
- Update tests whenever component behavior, docs generation, or JS hooks change.

## Documentation Requirements

- Keep docs split by audience:
  - `README.md` is user-facing installation/usage guidance.
  - `CONTRIBUTING.md` is contributor workflow and project maintenance guidance.
- Update both `README.md`/`CONTRIBUTING.md` (as applicable) and `PROGRESS.md` for any material feature/workflow change.
- `PROGRESS.md` must include:
  - current validated command set
  - remaining work/incomplete items
  - milestone and commit-log updates
- Public component changes should include in-module docs and examples.

## Release Flow

1. Update `mix.exs` version + `CHANGELOG.md`.
2. Run all quality/test/browser commands above.
3. Publish package/docs to Hex (currently manual).
4. Publish GitHub release (triggers Pages deploy via `.github/workflows/publish-site.yml`).
