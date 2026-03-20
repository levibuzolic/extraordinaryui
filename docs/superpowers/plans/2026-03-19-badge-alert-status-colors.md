# Badge & Alert Status Color Refactor

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Separate color and variant concerns in badge component, add success/warning/info tokens, update both badge and alert to use consistent status colors.

**Architecture:** Add three new CSS color tokens (success, warning, info) with light/dark variants. Refactor badge to accept `color` (primary|secondary|destructive|success|warning|info) and `variant` (:solid|:outline|:ghost|:link) as separate props with sensible defaults. Update alert to use the same color tokens for consistency.

**Tech Stack:** Elixir, Phoenix LiveView, Tailwind CSS, OKLch color space

---

## File Structure

**Modified files:**
- `priv/templates/cinder_ui.css` — Add success, warning, info CSS variables
- `lib/cinder_ui/components/feedback.ex` — Refactor badge and alert components

**Test/Example files:**
- `demo/lib/demo_web/live/components_live.ex` — Update badge examples
- Existing browser tests will validate the changes

---

## Task Breakdown

### Task 1: Add CSS Color Variables

**Files:**
- Modify: `priv/templates/cinder_ui.css:40-76` (light and dark theme blocks)

**Context:** The file currently defines color tokens like `--primary`, `--destructive`. We need to add `--success`, `--warning`, `--info` for both light and dark modes using OKLch color space (consistent with existing tokens).

- [ ] **Step 1: Add success, warning, info to light theme**

After line 22 (`--destructive-foreground: oklch(0.985 0 0);`), add:

```css
--success: oklch(0.656 0.172 142.495);
--success-foreground: oklch(0.985 0 0);
--warning: oklch(0.714 0.155 70.08);
--warning-foreground: oklch(0.985 0 0);
--info: oklch(0.651 0.213 259.361);
--info-foreground: oklch(0.985 0 0);
```

- [ ] **Step 2: Add success, warning, info to dark theme**

After line 58 (`--destructive-foreground: oklch(0.985 0 0);` in dark theme), add:

```css
--success: oklch(0.556 0.175 142.495);
--success-foreground: oklch(0.985 0 0);
--warning: oklch(0.596 0.174 70.08);
--warning-foreground: oklch(0.985 0 0);
--info: oklch(0.696 0.17 262.48);
--info-foreground: oklch(0.985 0 0);
```

- [ ] **Step 3: Add color theme mappings**

After line 100 (`--color-chart-3: var(--chart-3);`), add:

```css
--color-success: var(--success);
--color-success-foreground: var(--success-foreground);
--color-warning: var(--warning);
--color-warning-foreground: var(--warning-foreground);
--color-info: var(--info);
--color-info-foreground: var(--info-foreground);
```

- [ ] **Step 4: Verify CSS is valid**

Run: `cd demo && npm run assets.build`
Expected: No CSS errors, build succeeds

- [ ] **Step 5: Commit**

```bash
git add priv/templates/cinder_ui.css
git commit -m "feat: add success, warning, info CSS color tokens"
```

---

### Task 2: Refactor Badge Component - API Design

**Files:**
- Modify: `lib/cinder_ui/components/feedback.ex:24-86` (badge component)

**Context:** The badge component currently has a single `variant` prop mapping to hardcoded style strings. We need to separate `color` and `variant` into two props, creating a matrix of combinations.

- [ ] **Step 1: Replace variant map with color and variant maps**

Replace the `@badge_variants` map (lines 24-33) with:

```elixir
@badge_colors %{
  primary: "primary",
  secondary: "secondary",
  destructive: "destructive",
  success: "success",
  warning: "warning",
  info: "info"
}

@badge_variants %{
  solid: %{
    primary: "bg-primary text-primary-foreground [a&]:hover:bg-primary/90",
    secondary: "bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/90",
    destructive: "bg-destructive text-white [a&]:hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40 dark:bg-destructive/60",
    success: "bg-success text-success-foreground [a&]:hover:bg-success/90",
    warning: "bg-warning text-warning-foreground [a&]:hover:bg-warning/90",
    info: "bg-info text-info-foreground [a&]:hover:bg-info/90"
  },
  outline: %{
    primary: "border-primary text-primary [a&]:hover:bg-primary [a&]:hover:text-primary-foreground",
    secondary: "border-secondary text-secondary [a&]:hover:bg-secondary [a&]:hover:text-secondary-foreground",
    destructive: "border-destructive text-destructive [a&]:hover:bg-destructive [a&]:hover:text-destructive-foreground",
    success: "border-success text-success [a&]:hover:bg-success [a&]:hover:text-success-foreground",
    warning: "border-warning text-warning [a&]:hover:bg-warning [a&]:hover:text-warning-foreground",
    info: "border-info text-info [a&]:hover:bg-info [a&]:hover:text-info-foreground"
  },
  ghost: %{
    primary: "[a&]:hover:bg-primary/10 [a&]:hover:text-primary",
    secondary: "[a&]:hover:bg-secondary/10 [a&]:hover:text-secondary",
    destructive: "[a&]:hover:bg-destructive/10 [a&]:hover:text-destructive",
    success: "[a&]:hover:bg-success/10 [a&]:hover:text-success",
    warning: "[a&]:hover:bg-warning/10 [a&]:hover:text-warning",
    info: "[a&]:hover:bg-info/10 [a&]:hover:text-info"
  },
  link: %{
    primary: "text-primary underline-offset-4 [a&]:hover:underline",
    secondary: "text-secondary underline-offset-4 [a&]:hover:underline",
    destructive: "text-destructive underline-offset-4 [a&]:hover:underline",
    success: "text-success underline-offset-4 [a&]:hover:underline",
    warning: "text-warning underline-offset-4 [a&]:hover:underline",
    info: "text-info underline-offset-4 [a&]:hover:underline"
  }
}
```

- [ ] **Step 2: Update badge doc string**

Replace the doc (lines 35-63) with:

```elixir
doc("""
Renders a status badge.

## Colors

`:primary` (default), `:secondary`, `:destructive`, `:success`, `:warning`, `:info`

## Variants

`:solid` (default), `:outline`, `:ghost`, `:link`

## Examples

```heex title="Default badge"
<.badge>New</.badge>
```

```heex title="Status colors"
<div class="flex flex-wrap items-center gap-2">
  <.badge>Default</.badge>
  <.badge color={:success}>Completed</.badge>
  <.badge color={:warning}>Pending</.badge>
  <.badge color={:info}>Beta</.badge>
</div>
```

```heex title="Color with variant"
<div class="flex flex-wrap items-center gap-2">
  <.badge color={:warning} variant={:outline}>In Review</.badge>
  <.badge color={:success} variant={:ghost}>Active</.badge>
  <.badge color={:info} variant={:link}>Documentation</.badge>
</div>
```

```heex title="Badge with icon"
<.badge color={:success}>
  <CinderUI.Icons.icon name="check" />
  Verified
</.badge>
```
""")
```

- [ ] **Step 3: Update badge attributes**

Replace attrs (lines 65-71) with:

```elixir
attr :color, :atom,
  default: :primary,
  values: [:primary, :secondary, :destructive, :success, :warning, :info]

attr :variant, :atom,
  default: :solid,
  values: [:solid, :outline, :ghost, :link]

attr :class, :string, default: nil
attr :rest, :global
slot :inner_block, required: true
```

- [ ] **Step 4: Update badge implementation function**

Replace the `def badge` function (lines 73-86) with:

```elixir
def badge(assigns) do
  variant_styles = @badge_variants[assigns.variant] || @badge_variants.solid

  assigns =
    assign(assigns, :classes, [
      "inline-flex items-center justify-center rounded-full border border-transparent px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0 [&>svg]:size-3 gap-1 [&>svg]:pointer-events-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive transition-[color,box-shadow] overflow-hidden",
      variant_styles[assigns.color] || variant_styles[:primary],
      assigns.class
    ])

  ~H"""
  <span data-slot="badge" data-color={@color} data-variant={@variant} class={classes(@classes)} {@rest}>
    {render_slot(@inner_block)}
  </span>
  """
end
```

- [ ] **Step 5: Verify badge component compiles**

Run: `cd demo && mix compile`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/cinder_ui/components/feedback.ex
git commit -m "refactor: separate badge color and variant props"
```

---

### Task 3: Update Alert Component to Use CSS Variables

**Files:**
- Modify: `lib/cinder_ui/components/feedback.ex:88-150` (alert component)

**Context:** The alert component currently hardcodes Tailwind colors (emerald-500, amber-500). Replace with CSS variable-based colors for consistency with badge.

- [ ] **Step 1: Replace alert variants map**

Replace `@alert_variants` (lines 88-94) with:

```elixir
@alert_variants %{
  default: "bg-card text-card-foreground",
  destructive: "border-destructive/30 bg-destructive/10 text-destructive [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90",
  success: "border-success/30 bg-success/10 text-success [&>svg]:text-current *:data-[slot=alert-description]:text-success/90",
  warning: "border-warning/30 bg-warning/10 text-warning [&>svg]:text-current *:data-[slot=alert-description]:text-warning/90",
  info: "border-info/30 bg-info/10 text-info [&>svg]:text-current *:data-[slot=alert-description]:text-info/90"
}
```

- [ ] **Step 2: Update alert variant attribute**

Change line 125 from:
```elixir
attr :variant, :atom, default: :default, values: [:default, :destructive, :success, :warning]
```

To:
```elixir
attr :variant, :atom, default: :default, values: [:default, :destructive, :success, :warning, :info]
```

- [ ] **Step 3: Update alert doc string**

Update the doc comment (lines 96-122) to include info variant in examples.

- [ ] **Step 4: Verify alert component compiles**

Run: `cd demo && mix compile`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add lib/cinder_ui/components/feedback.ex
git commit -m "refactor: update alert to use CSS variable colors"
```

---

### Task 4: Run Tests

**Files:**
- Test: `demo/test/` (all feedback component tests)

- [ ] **Step 1: Run feedback component tests**

Run: `cd demo && mix test test/components/feedback_test.exs -v`
Expected: All tests pass

- [ ] **Step 2: Run all demo tests**

Run: `cd demo && mix test`
Expected: All tests pass

- [ ] **Step 3: Commit if needed**

```bash
git add -A
git commit -m "test: verify badge and alert changes pass all tests"
```

---

### Task 5: Update Demo Examples

**Files:**
- Modify: `demo/lib/demo_web/live/components_live.ex` (badge examples)

**Context:** The demo app shows component examples. Update badge examples to showcase the new color and variant separation.

- [ ] **Step 1: Find badge examples in demo**

Search for badge usage and update them with comprehensive examples showing all colors and variants.

- [ ] **Step 2: Commit**

```bash
git add demo/lib/demo_web/live/components_live.ex
git commit -m "docs: update badge examples to showcase color/variant separation"
```

---

### Task 6: Visual Verification

**Files:**
- Test: Browser-based visual inspection

- [ ] **Step 1: Start demo app**

Run: `cd demo && mix phx.server`
Expected: App starts on http://localhost:4000

- [ ] **Step 2: Navigate to components page**

Open http://localhost:4000 and view badge/alert sections

- [ ] **Step 3: Verify visuals**

- [ ] Badge colors display correctly (all 6 colors × 4 variants)
- [ ] Alert variants display correctly (success, warning, info use CSS variables)
- [ ] Light/dark mode toggle switches colors appropriately
- [ ] No console errors in browser

- [ ] **Step 4: Stop app**

Ctrl+C to stop the demo server

---

### Task 7: Final Quality Checks

**Files:**
- All modified files

- [ ] **Step 1: Run quality checks**

Run: `mix quality`
Expected: All checks pass

- [ ] **Step 2: Run coverage**

Run: `env MIX_ENV=test mix coveralls.cobertura --raise`
Expected: Coverage meets threshold (90%)

- [ ] **Step 3: Build docs**

Run: `mix cinder_ui.docs.build`
Expected: Docs build without errors

---

## Summary

7 tasks total:
1. Add CSS color variables (success, warning, info)
2. Refactor badge component (separate color/variant props)
3. Update alert component (use CSS variables)
4. Run all tests
5. Update demo examples
6. Visual verification
7. Final quality checks
