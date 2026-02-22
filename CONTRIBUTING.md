# Contributing to Extraordinary UI

Thanks for contributing. This guide is for humans first: the goal is to help you get productive quickly, run the right checks, and submit high-signal changes.

## Ground Rules

- Keep APIs Phoenix-first (`attr`/`slot`-typed function components, clear HEEx usage).
- Keep styles aligned with shadcn conventions and token model.
- Prefer composition with Extraordinary UI components in docs/examples.
- Ship tests with behavior changes.
- Keep `README.md` user-focused and keep contributor workflow docs here.

## Prerequisites

- Elixir (via `mise` is recommended in this repo)
- Node.js + npm (for sandbox asset and browser tests)
- Chromium for Playwright (`npx playwright install --with-deps chromium`)

## Local Setup

```bash
mix deps.get
cd sandbox/demo_app && mix deps.get && npm ci
```

## Development Workspaces

- Library: `lib/extraordinary_ui/**`
- Static docs/site tasks: `lib/mix/tasks/**`
- Static docs catalog definitions: `lib/extraordinary_ui/docs/catalog.ex`
- Sandbox integration app: `sandbox/demo_app`
- Browser tests: `sandbox/demo_app/tests/browser/**`

## Typical Workflow

1. Implement the component/task change in library code.
2. Update docs/examples if API or behavior changed.
3. Update static docs catalog sample(s) in `lib/extraordinary_ui/docs/catalog.ex`.
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
mix extraordinary_ui.docs.build --output tmp/ci-docs --clean
mix extraordinary_ui.site.build --output tmp/ci-site --clean
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
3. Publish to Hex (currently manual):

```bash
mix hex.publish
mix hex.publish docs
```

4. Publish GitHub release (triggers Pages deploy via `.github/workflows/publish-site.yml`).

## Need Help?

If you are unsure where to implement a change:

- API and behavior: component module in `lib/extraordinary_ui/components/**`
- docs examples/static pages: `lib/extraordinary_ui/docs/catalog.ex` and docs build task
- browser behavior regressions: `sandbox/demo_app/tests/browser/**`

Open a draft PR early for architecture feedback.
