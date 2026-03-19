# Alert Component Slots Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert alert component from nested title/description components to named slots for cleaner, more composable API.

**Architecture:** The alert component will accept `:title` and `:description` named slots instead of using `alert_title/1` and `alert_description/1` subcomponents. The CSS grid layout remains unchanged. Old components are removed entirely (breaking change).

**Tech Stack:** Elixir, Phoenix LiveView, HEEx templates

---

## File Structure

**Modified files:**
- `lib/cinder_ui/components/feedback.ex` — Update alert/1, remove alert_title/1 and alert_description/1
- `test/cinder_ui/components/feedback_test.exs` — Update alert tests to use slot API
- `dev/lib/cinder_ui/docs/ui_components/catalog.ex` — Update alert examples

---

## Task Breakdown

### Task 1: Update Alert Component - Add Slots

**Files:**
- Modify: `lib/cinder_ui/components/feedback.ex:190-300` (alert component and related functions)

**Context:** The alert component currently uses nested components. We need to add `:title` and `:description` slots and update the implementation to render them in the correct grid positions.

- [ ] **Step 1: Update alert component attributes**

Replace the current attrs section with:

```elixir
attr :id, :string, default: nil
attr :variant, :atom, default: :default, values: [:default, :destructive, :success, :warning, :info]
attr :class, :string, default: nil
attr :rest, :global
slot :inner_block, required: true
slot :title
slot :description
```

- [ ] **Step 2: Update alert implementation function**

Replace the `def alert(assigns)` function body to:

```elixir
def alert(assigns) do
  assigns =
    assign(assigns, :classes, [
      "relative w-full rounded-lg border px-4 py-3 text-sm grid has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr] has-[>svg]:gap-x-3 gap-y-0.5 items-start has-[>svg]:[&>svg]:row-span-2 [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current",
      variant(@alert_variants, assigns.variant, @alert_variants.default),
      assigns.class
    ])

  ~H"""
  <div
    id={@id}
    data-slot="alert"
    data-variant={@variant}
    role="alert"
    class={classes(@classes)}
    {@rest}
  >
    {render_slot(@inner_block)}
    <div :if={@title != []} data-slot="alert-title" class="col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight">
      {render_slot(@title)}
    </div>
    <div :if={@description != []} data-slot="alert-description" class="col-start-2 text-sm opacity-90">
      {render_slot(@description)}
    </div>
  </div>
  """
end
```

- [ ] **Step 3: Update alert doc string**

Replace the doc comment (lines 202-275) with:

```elixir
doc("""
Renders an alert container with optional title and description slots.

## Variants

`:default`, `:destructive`, `:success`, `:warning`, `:info`

## Examples

```heex title="Default alert" align="full"
<.alert>
  <CinderUI.Icons.icon name="circle-alert" />
  <:title>Heads up!</:title>
  <:description>
    You can add components to your app using the install task.
  </:description>
</.alert>
```

```heex title="All alert variants" align="full"
<div class="space-y-4">
  <div>
    <h4 class="text-sm font-medium mb-2">Destructive</h4>
    <.alert variant={:destructive}>
      <CinderUI.Icons.icon name="triangle-alert" />
      <:title>Unable to deploy</:title>
      <:description>
        Your build failed. Check logs and try again.
      </:description>
    </.alert>
  </div>

  <div>
    <h4 class="text-sm font-medium mb-2">Success</h4>
    <.alert variant={:success}>
      <CinderUI.Icons.icon name="circle-check-big" />
      <:title>Changes saved</:title>
      <:description>
        Your updates have been successfully saved to the server.
      </:description>
    </.alert>
  </div>

  <div>
    <h4 class="text-sm font-medium mb-2">Warning</h4>
    <.alert variant={:warning}>
      <CinderUI.Icons.icon name="triangle-alert" />
      <:title>Deprecated API</:title>
      <:description>
        This endpoint will be removed in v2.0. Migrate to the new API.
      </:description>
    </.alert>
  </div>

  <div>
    <h4 class="text-sm font-medium mb-2">Info</h4>
    <.alert variant={:info}>
      <CinderUI.Icons.icon name="info" />
      <:title>New feature available</:title>
      <:description>
        Check out the documentation for details on using this feature.
      </:description>
    </.alert>
  </div>
</div>
```
""")
```

- [ ] **Step 4: Remove alert_title component**

Delete the entire `alert_title/1` function (find it in the file, should be a small function with attrs and implementation).

- [ ] **Step 5: Remove alert_description component**

Delete the entire `alert_description/1` function (should be similar in structure to alert_title).

- [ ] **Step 6: Verify compilation**

Run: `cd demo && mix compile`
Expected: No errors or warnings

- [ ] **Step 7: Commit**

```bash
git add lib/cinder_ui/components/feedback.ex
git commit -m "refactor: convert alert to use named slots"
```

---

### Task 2: Update Tests

**Files:**
- Modify: `test/cinder_ui/components/feedback_test.exs` (alert tests)

**Context:** Update all alert tests to use the new slot API instead of the old component API.

- [ ] **Step 1: Find and update alert tests**

Search for all tests that use `.alert_title` or `.alert_description` and update them to use the slot syntax:
- Change `<.alert_title>Text</.alert_title>` to `<:title>Text</:title>`
- Change `<.alert_description>Text</.alert_description>` to `<:description>Text</:description>`

- [ ] **Step 2: Run tests**

Run: `cd demo && mix test test/cinder_ui/components/feedback_test.exs -v`
Expected: All alert tests pass

- [ ] **Step 3: Commit**

```bash
git add test/cinder_ui/components/feedback_test.exs
git commit -m "test: update alert tests to use slot API"
```

---

### Task 3: Update Demo Examples

**Files:**
- Modify: `dev/lib/cinder_ui/docs/ui_components/catalog.ex` (alert examples)

**Context:** Update alert examples in the catalog to use the new slot API.

- [ ] **Step 1: Find alert examples in catalog**

Search for alert component usage in the catalog file.

- [ ] **Step 2: Update examples**

Replace all `.alert_title` and `.alert_description` with the new slot syntax.

- [ ] **Step 3: Run docs build**

Run: `mix cinder_ui.docs.build`
Expected: Docs build successfully without errors

- [ ] **Step 4: Commit**

```bash
git add dev/lib/cinder_ui/docs/ui_components/catalog.ex
git commit -m "docs: update alert examples to use slots"
```

---

### Task 4: Final Quality Checks

**Files:**
- All modified files

**Context:** Run comprehensive checks to ensure the refactor is complete and correct.

- [ ] **Step 1: Run all tests**

Run: `cd demo && mix test`
Expected: All 141 tests pass

- [ ] **Step 2: Run quality checks**

Run: `mix quality`
Expected: All checks pass (formatting, compilation, credo, coverage)

- [ ] **Step 3: Verify coverage**

Run: `env MIX_ENV=test mix coveralls.cobertura --raise`
Expected: Coverage meets 90% threshold

- [ ] **Step 4: Final commit (if needed)**

If any formatting changes were made automatically, commit them:

```bash
git add -A
git commit -m "chore: final cleanup after alert slots refactor"
```

---

## Summary

4 tasks total:
1. Update alert component to use slots, remove old components
2. Update all tests to use new slot API
3. Update demo examples
4. Final quality checks

Total estimated time: 1-2 hours for an experienced developer.
