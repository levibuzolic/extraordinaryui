# Contributing to Cinder UI

Thanks for contributing. This guide is for humans first: the goal is to help you get productive quickly, run the right checks, and submit high-signal changes.

## Ground Rules

- Keep APIs Phoenix-first (`attr`/`slot`-typed function components, clear HEEx usage).
- Keep styles aligned with shadcn conventions and token model.
- Prefer composition with Cinder UI components in docs/examples.
- Ship tests with behavior changes.
- Keep `README.md` user-focused and keep contributor workflow docs here.

## Prerequisites

- Elixir (via `mise` is recommended in this repo)
- Node.js + npm (for sandbox asset and browser tests)
- Chromium for Playwright (`npx playwright install --with-deps chromium`)

## Local Setup

```bash
./bin/bootstrap
```

Notes:

- `./bin/bootstrap` runs `mise trust`, `mise install`, and dependency installation for both the repo root and `sandbox/demo_app`.
- Root package includes `lucide_icons` as an optional dependency for `CinderUI.Icons.icon/1` and icon-backed component primitives.
- Sandbox includes `lucide_icons` directly so browser/docs examples always render icon previews.
- Hex package artifacts intentionally ship only runtime modules and `mix cinder_ui.install`; static docs/site build tasks remain repository-only maintainer tooling.

## Development Workspaces

- Library: `lib/cinder_ui/**`
- Static docs/site tasks: `lib/mix/tasks/**`
- Static docs catalog definitions: `lib/cinder_ui/docs/catalog.ex`
- Sandbox integration app: `sandbox/demo_app`
- Browser tests: `sandbox/demo_app/tests/browser/**`

## Typical Workflow

1. Implement the component/task change in library code.
2. Update docs/examples if API or behavior changed.
3. Update static docs catalog sample(s) in `lib/cinder_ui/docs/catalog.ex`.
4. Add or adjust unit/browser tests.
5. Run quality gates.
6. Update `PROGRESS.md` milestones/commit log for material changes.

## Quality Gates

Run from repo root unless noted.

### Root quality + tests

```bash
mix quality
MIX_ENV=test mix coveralls.cobertura --raise
```

### Static exports

```bash
mix cinder_ui.docs.build --output tmp/ci-docs --clean
mix cinder_ui.site.build --output tmp/ci-site --clean
```

### Sandbox unit tests

```bash
cd sandbox/demo_app
mix format --check-formatted
mix test
```

### Browser tests (Playwright)

```bash
cd sandbox/demo_app
mix assets.build
npx playwright test
```

Visual suite only:

```bash
cd sandbox/demo_app
npx playwright test tests/browser/visual.spec.ts
```

Update visual baselines (only when UI change is intentional):

```bash
cd sandbox/demo_app
npx playwright test tests/browser/visual.spec.ts --update-snapshots
```

## Documentation Expectations

- `README.md`: only user-facing install/usage/docs guidance.
- `CONTRIBUTING.md`: maintainer and contributor workflow.
- `PROGRESS.md`: keep plan, completed milestones, remaining work, and commit log current.
- Module/function docs: use markdown, include realistic examples, and include multiple named fenced HEEx examples where useful.

Example inline docs pattern:

~~~elixir
@doc """
```heex title="Primary"
<.button>Save</.button>
```

```heex title="Secondary"
<.button variant={:outline}>Cancel</.button>
```
"""
~~~

## Pull Request Checklist

- [ ] Change is scoped and documented.
- [ ] Unit tests updated/passing.
- [ ] Browser tests updated/passing (if UI/interaction changed).
- [ ] Static docs/site build successfully.
- [ ] `PROGRESS.md` updated for material milestones.
- [ ] Snapshots updated only for intentional visual changes.

## Commit Style

Use concise, scoped commit messages. Existing style examples:

- `docs(samples): expand rich component examples`
- `test(visual): stabilize snapshots for cross-env size jitter`
- `docs(progress): log milestone update`

## Release Process

1. Update version and changelog (`mix.exs`, `CHANGELOG.md`).
2. Run all quality gates above.
3. Confirm release secrets/environments are configured (one-time setup below).
4. Site deploys automatically on every `main` push via `.github/workflows/publish-site.yml`.
5. Publish GitHub release (triggers `.github/workflows/publish-hex.yml` and also runs `.github/workflows/publish-site.yml`).
5. If needed, run `.github/workflows/publish-hex.yml` manually with `workflow_dispatch`.

### One-Time Hex Publish Automation Setup

1. Generate a Hex API key scoped for publishing:

```bash
mix hex.user key generate --key-name github-actions-publish --permission api:write
```

2. In GitHub repository settings, create secret `HEX_API_KEY`.
3. (Recommended) Create environment `hex-publish` and attach `HEX_API_KEY` there.
4. (Recommended) Add required reviewers to `hex-publish` environment for release gating.

Manual fallback commands (if automation is unavailable):

```bash
mix hex.publish
mix hex.publish docs
```

## Need Help?

If you are unsure where to implement a change:

- API and behavior: component module in `lib/cinder_ui/components/**`
- docs examples/static pages: `lib/cinder_ui/docs/catalog.ex` and docs build task
- browser behavior regressions: `sandbox/demo_app/tests/browser/**`

Open a draft PR early for architecture feedback.
