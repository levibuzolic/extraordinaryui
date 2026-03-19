# Alert Component Slots Refactor Design

**Goal:** Convert the alert component from using nested title/description components to using named slots for a cleaner, more composable API.

**Scope:** Refactor `alert/1`, remove `alert_title/1` and `alert_description/1` components, update all examples and tests.

---

## Current State

The alert component currently uses:
- `alert/1` - Main container
- `alert_title/1` - Optional title subcomponent
- `alert_description/1` - Optional description subcomponent

**Current usage:**
```heex
<.alert variant={:success}>
  <CinderUI.Icons.icon name="check" />
  <.alert_title>Success</.alert_title>
  <.alert_description>Saved successfully</.alert_description>
</.alert>
```

---

## Proposed Design

### New Alert API with Named Slots

**New usage:**
```heex
<.alert variant={:success}>
  <CinderUI.Icons.icon name="check" />
  <:title>Success</:title>
  <:description>Saved successfully</:description>
</.alert>
```

### Component Definition

**Attributes:**
- `variant` - `:default`, `:destructive`, `:success`, `:warning`, `:info` (required, default: `:default`)
- `id` - Optional element ID
- `class` - Additional CSS classes
- `rest` - Global HTML attributes

**Slots:**
- `:title` - Optional title content (renders in title area)
- `:description` - Optional description content (renders in description area)
- `:inner_block` - Icon, content, or other elements (renders in grid start position)

**CSS Grid layout:**
- If icon present: 3-column grid (icon, title+description, action)
- Title and description span to end of row
- Icon positioned first

### Removed Components

These components will be completely removed:
- `alert_title/1`
- `alert_description/1`

All code using these must migrate to the slot API.

### Examples After Refactor

**Basic alert with all parts:**
```heex
<.alert variant={:destructive}>
  <CinderUI.Icons.icon name="triangle-alert" />
  <:title>Error</:title>
  <:description>Something went wrong</:description>
</.alert>
```

**Icon-only alert:**
```heex
<.alert>
  <CinderUI.Icons.icon name="info" />
</.alert>
```

**Custom content without slots:**
```heex
<.alert variant={:success}>
  <div class="custom-content">
    <strong>Success!</strong>
  </div>
</.alert>
```

**With action elements:**
```heex
<.alert variant={:warning}>
  <CinderUI.Icons.icon name="triangle-alert" />
  <:title>Warning</:title>
  <:description>Review required</:description>
  <button class="ml-auto">Dismiss</button>
</.alert>
```

---

## Implementation Plan

### Files to Modify

1. **lib/cinder_ui/components/feedback.ex**
   - Update `alert/1` component to use slots instead of nested components
   - Remove `alert_title/1` function
   - Remove `alert_description/1` function
   - Update doc examples

2. **test/cinder_ui/components/feedback_test.exs**
   - Update alert tests to use new slot API

3. **dev/lib/cinder_ui/docs/ui_components/catalog.ex**
   - Update alert examples to use slot API

4. **Any other files referencing alert components**
   - Search and update all usage

### Step-by-Step

1. Update `alert/1` component:
   - Add `:title` and `:description` slots to component definition
   - Update implementation to render slots in correct grid positions
   - Keep the same CSS classes and grid structure
   - Update doc strings with new examples

2. Remove old components:
   - Delete `alert_title/1` function
   - Delete `alert_description/1` function
   - Update docs reference to show only `alert/1`

3. Update all references:
   - Find and update all `.alert_title` and `.alert_description` usages
   - Update test assertions

4. Test:
   - Run all tests to ensure nothing breaks
   - Verify examples render correctly

---

## Backward Compatibility

**Breaking change:** Yes. The old component API (`alert_title/1`, `alert_description/1`) is removed. All existing code must migrate to the slot API.

**Migration path:**
- Simple find/replace: `<.alert_title>` → `<:title>` and `<.alert_description>` → `<:description>`
- Close the `/>`  closing tags and convert to slot syntax

---

## Success Criteria

- [ ] `alert/1` accepts `:title` and `:description` slots
- [ ] `alert_title/1` and `alert_description/1` are removed
- [ ] All examples use new slot syntax
- [ ] All tests pass
- [ ] Doc examples render correctly with new API
- [ ] CSS grid layout still works correctly
- [ ] Light and dark modes work with new API
