# Theme System Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix sidebar theming to respond to color theme changes and update theme colors to match shadcn UI's official palette.

**Architecture:** Update the theme system to apply sidebar-specific CSS tokens to the sidebar element, and replace the custom theme presets with shadcn UI's official themes (Neutral, Stone, Zinc, Mauve, Olive, Mist, Taupe). This ensures the sidebar background updates with theme selection and aligns the color system with the design system source of truth.

**Tech Stack:** Vanilla JavaScript (static_docs.js), CSS custom properties, shadcn UI color system

---

## File Structure

**Modified files:**
- `dev/assets/docs/static_docs.js` — Update theme presets to match shadcn UI colors, fix sidebar token application
- `dev/assets/site/site.html` or theme selector template — Update theme names in color picker

---

## Task Breakdown

### Task 1: Update Theme Presets to shadcn UI Official Colors

**Files:**
- Modify: `dev/assets/docs/static_docs.js:97-312` (themePresets object and related code)

**Context:** Replace the current theme presets (zinc, slate, stone, gray, neutral) with shadcn UI's official themes (Neutral, Stone, Zinc, Mauve, Olive, Mist, Taupe). Use the exact color values from shadcn UI's source.

**shadcn UI Official Theme Colors (from https://github.com/shadcn-ui/ui/blob/main/apps/www/lib/theme.ts):**

Light mode tokens follow this pattern:
- foreground, primary, primary-foreground, secondary, secondary-foreground, muted, muted-foreground, accent, accent-foreground, border, input, ring
Dark mode adds: background, card, card-foreground, popover, popover-foreground

**Implementation steps:**

- [ ] **Step 1: Replace themePresets with shadcn UI colors**

Replace the entire `themePresets` object (lines 97-293) with:

```javascript
const themePresets = {
  neutral: {
    light: {
      foreground: "oklch(0.145 0 0)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.145 0 0)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.145 0 0)",
      primary: "oklch(0.205 0 0)",
      "primary-foreground": "oklch(0.985 0 0)",
      secondary: "oklch(0.97 0 0)",
      "secondary-foreground": "oklch(0.205 0 0)",
      muted: "oklch(0.97 0 0)",
      "muted-foreground": "oklch(0.556 0 0)",
      accent: "oklch(0.97 0 0)",
      "accent-foreground": "oklch(0.205 0 0)",
      border: "oklch(0.922 0 0)",
      input: "oklch(0.922 0 0)",
      ring: "oklch(0.708 0 0)",
    },
    dark: {
      background: "oklch(0.145 0 0)",
      foreground: "oklch(0.985 0 0)",
      card: "oklch(0.205 0 0)",
      "card-foreground": "oklch(0.985 0 0)",
      popover: "oklch(0.205 0 0)",
      "popover-foreground": "oklch(0.985 0 0)",
      primary: "oklch(0.922 0 0)",
      "primary-foreground": "oklch(0.205 0 0)",
      secondary: "oklch(0.269 0 0)",
      "secondary-foreground": "oklch(0.985 0 0)",
      muted: "oklch(0.269 0 0)",
      "muted-foreground": "oklch(0.708 0 0)",
      accent: "oklch(0.269 0 0)",
      "accent-foreground": "oklch(0.985 0 0)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.556 0 0)",
    },
  },
  stone: {
    light: {
      foreground: "oklch(0.147 0.004 49.25)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.147 0.004 49.25)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.147 0.004 49.25)",
      primary: "oklch(0.216 0.006 56.043)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.97 0.001 106.424)",
      "secondary-foreground": "oklch(0.216 0.006 56.043)",
      muted: "oklch(0.97 0.001 106.424)",
      "muted-foreground": "oklch(0.553 0.013 58.071)",
      accent: "oklch(0.97 0.001 106.424)",
      "accent-foreground": "oklch(0.216 0.006 56.043)",
      border: "oklch(0.923 0.003 48.717)",
      input: "oklch(0.923 0.003 48.717)",
      ring: "oklch(0.709 0.01 56.259)",
    },
    dark: {
      background: "oklch(0.147 0.004 49.25)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.216 0.006 56.043)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.216 0.006 56.043)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.923 0.003 48.717)",
      "primary-foreground": "oklch(0.216 0.006 56.043)",
      secondary: "oklch(0.268 0.007 34.298)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.268 0.007 34.298)",
      "muted-foreground": "oklch(0.709 0.01 56.259)",
      accent: "oklch(0.268 0.007 34.298)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.553 0.013 58.071)",
    },
  },
  zinc: {
    light: {
      foreground: "oklch(0.141 0.005 285.823)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.141 0.005 285.823)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.141 0.005 285.823)",
      primary: "oklch(0.21 0.006 285.885)",
      "primary-foreground": "oklch(0.985 0 0)",
      secondary: "oklch(0.967 0.001 286.375)",
      "secondary-foreground": "oklch(0.21 0.006 285.885)",
      muted: "oklch(0.967 0.001 286.375)",
      "muted-foreground": "oklch(0.552 0.016 285.938)",
      accent: "oklch(0.967 0.001 286.375)",
      "accent-foreground": "oklch(0.21 0.006 285.885)",
      border: "oklch(0.92 0.004 286.32)",
      input: "oklch(0.92 0.004 286.32)",
      ring: "oklch(0.705 0.015 286.067)",
    },
    dark: {
      background: "oklch(0.141 0.005 285.823)",
      foreground: "oklch(0.985 0 0)",
      card: "oklch(0.21 0.006 285.885)",
      "card-foreground": "oklch(0.985 0 0)",
      popover: "oklch(0.21 0.006 285.885)",
      "popover-foreground": "oklch(0.985 0 0)",
      primary: "oklch(0.92 0.004 286.32)",
      "primary-foreground": "oklch(0.21 0.006 285.885)",
      secondary: "oklch(0.274 0.006 286.033)",
      "secondary-foreground": "oklch(0.985 0 0)",
      muted: "oklch(0.274 0.006 286.033)",
      "muted-foreground": "oklch(0.705 0.015 286.067)",
      accent: "oklch(0.274 0.006 286.033)",
      "accent-foreground": "oklch(0.985 0 0)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.552 0.016 285.938)",
    },
  },
  mauve: {
    light: {
      foreground: "oklch(0.129 0.042 264.695)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.129 0.042 264.695)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.129 0.042 264.695)",
      primary: "oklch(0.208 0.042 265.755)",
      "primary-foreground": "oklch(0.984 0.003 247.858)",
      secondary: "oklch(0.968 0.007 247.896)",
      "secondary-foreground": "oklch(0.208 0.042 265.755)",
      muted: "oklch(0.968 0.007 247.896)",
      "muted-foreground": "oklch(0.554 0.046 257.417)",
      accent: "oklch(0.968 0.007 247.896)",
      "accent-foreground": "oklch(0.208 0.042 265.755)",
      border: "oklch(0.929 0.013 255.508)",
      input: "oklch(0.929 0.013 255.508)",
      ring: "oklch(0.704 0.04 256.788)",
    },
    dark: {
      background: "oklch(0.129 0.042 264.695)",
      foreground: "oklch(0.984 0.003 247.858)",
      card: "oklch(0.208 0.042 265.755)",
      "card-foreground": "oklch(0.984 0.003 247.858)",
      popover: "oklch(0.208 0.042 265.755)",
      "popover-foreground": "oklch(0.984 0.003 247.858)",
      primary: "oklch(0.929 0.013 255.508)",
      "primary-foreground": "oklch(0.208 0.042 265.755)",
      secondary: "oklch(0.279 0.041 260.031)",
      "secondary-foreground": "oklch(0.984 0.003 247.858)",
      muted: "oklch(0.279 0.041 260.031)",
      "muted-foreground": "oklch(0.704 0.04 256.788)",
      accent: "oklch(0.279 0.041 260.031)",
      "accent-foreground": "oklch(0.984 0.003 247.858)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.551 0.027 264.364)",
    },
  },
  olive: {
    light: {
      foreground: "oklch(0.144 0.013 101.487)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.144 0.013 101.487)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.144 0.013 101.487)",
      primary: "oklch(0.206 0.02 106.266)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.967 0.007 83.831)",
      "secondary-foreground": "oklch(0.206 0.02 106.266)",
      muted: "oklch(0.967 0.007 83.831)",
      "muted-foreground": "oklch(0.554 0.027 99.305)",
      accent: "oklch(0.967 0.007 83.831)",
      "accent-foreground": "oklch(0.206 0.02 106.266)",
      border: "oklch(0.928 0.015 100.425)",
      input: "oklch(0.928 0.015 100.425)",
      ring: "oklch(0.704 0.03 99.776)",
    },
    dark: {
      background: "oklch(0.144 0.013 101.487)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.206 0.02 106.266)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.206 0.02 106.266)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.928 0.015 100.425)",
      "primary-foreground": "oklch(0.206 0.02 106.266)",
      secondary: "oklch(0.272 0.024 108.528)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.272 0.024 108.528)",
      "muted-foreground": "oklch(0.704 0.03 99.776)",
      accent: "oklch(0.272 0.024 108.528)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.554 0.027 99.305)",
    },
  },
  mist: {
    light: {
      foreground: "oklch(0.138 0.039 265.975)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.138 0.039 265.975)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.138 0.039 265.975)",
      primary: "oklch(0.193 0.051 262.911)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.965 0.015 263.438)",
      "secondary-foreground": "oklch(0.193 0.051 262.911)",
      muted: "oklch(0.965 0.015 263.438)",
      "muted-foreground": "oklch(0.553 0.04 264.364)",
      accent: "oklch(0.965 0.015 263.438)",
      "accent-foreground": "oklch(0.193 0.051 262.911)",
      border: "oklch(0.925 0.022 264.531)",
      input: "oklch(0.925 0.022 264.531)",
      ring: "oklch(0.703 0.045 263.196)",
    },
    dark: {
      background: "oklch(0.138 0.039 265.975)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.193 0.051 262.911)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.193 0.051 262.911)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.925 0.022 264.531)",
      "primary-foreground": "oklch(0.193 0.051 262.911)",
      secondary: "oklch(0.267 0.042 258.657)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.267 0.042 258.657)",
      "muted-foreground": "oklch(0.703 0.045 263.196)",
      accent: "oklch(0.267 0.042 258.657)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.553 0.04 264.364)",
    },
  },
  taupe: {
    light: {
      foreground: "oklch(0.146 0.01 49.25)",
      card: "oklch(1 0 0)",
      "card-foreground": "oklch(0.146 0.01 49.25)",
      popover: "oklch(1 0 0)",
      "popover-foreground": "oklch(0.146 0.01 49.25)",
      primary: "oklch(0.21 0.014 49.269)",
      "primary-foreground": "oklch(0.985 0.001 106.423)",
      secondary: "oklch(0.969 0.007 40.998)",
      "secondary-foreground": "oklch(0.21 0.014 49.269)",
      muted: "oklch(0.969 0.007 40.998)",
      "muted-foreground": "oklch(0.554 0.015 49.269)",
      accent: "oklch(0.969 0.007 40.998)",
      "accent-foreground": "oklch(0.21 0.014 49.269)",
      border: "oklch(0.926 0.01 49.269)",
      input: "oklch(0.926 0.01 49.269)",
      ring: "oklch(0.706 0.019 49.269)",
    },
    dark: {
      background: "oklch(0.146 0.01 49.25)",
      foreground: "oklch(0.985 0.001 106.423)",
      card: "oklch(0.21 0.014 49.269)",
      "card-foreground": "oklch(0.985 0.001 106.423)",
      popover: "oklch(0.21 0.014 49.269)",
      "popover-foreground": "oklch(0.985 0.001 106.423)",
      primary: "oklch(0.926 0.01 49.269)",
      "primary-foreground": "oklch(0.21 0.014 49.269)",
      secondary: "oklch(0.271 0.012 40.998)",
      "secondary-foreground": "oklch(0.985 0.001 106.423)",
      muted: "oklch(0.271 0.012 40.998)",
      "muted-foreground": "oklch(0.706 0.019 49.269)",
      accent: "oklch(0.271 0.012 40.998)",
      "accent-foreground": "oklch(0.985 0.001 106.423)",
      border: "oklch(1 0 0 / 10%)",
      input: "oklch(1 0 0 / 15%)",
      ring: "oklch(0.554 0.015 49.269)",
    },
  },
}
```

- [ ] **Step 2: Verify themes compile**

Run: `cd demo && npm run build`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add dev/assets/docs/static_docs.js
git commit -m "chore: update theme colors to match shadcn UI official palette"
```

---

### Task 2: Fix Sidebar Theming

**Files:**
- Modify: `dev/assets/docs/static_docs.js:345-355` (applyPalette function)

**Context:** The sidebar CSS tokens are generated and stored on :root, but the sidebar element itself doesn't use them. We need to apply the sidebar tokens to the sidebar element so they take precedence.

- [ ] **Step 1: Update applyPalette function**

Replace the `applyPalette` function (lines 346-355) with:

```javascript
const applyPalette = (color, resolvedMode) => {
  const palette = themePresets[color] || themePresets.neutral
  const tokens = palette[resolvedMode]
  themedTokenKeys.forEach((token) => {
    root.style.removeProperty(`--${token}`)
  })
  Object.entries(tokens).forEach(([token, value]) => {
    root.style.setProperty(`--${token}`, value)
  })

  // Apply sidebar tokens to the sidebar element so it uses the themed colors
  if (sidebar) {
    Object.entries(tokens).forEach(([token, value]) => {
      if (token.startsWith('sidebar-')) {
        sidebar.style.setProperty(`--${token}`, value)
      }
    })
  }
}
```

- [ ] **Step 2: Update sidebar HTML**

The sidebar needs to use the CSS variables. Check the HTML template that renders the sidebar and ensure it uses `--sidebar`, `--sidebar-foreground`, etc. classes. This is likely in:
- `dev/lib/cinder_ui/site/layouts/docs_layout.html.heex` or similar

Ensure the sidebar element has classes like:
```heex
class="bg-sidebar text-sidebar-foreground"
```

- [ ] **Step 3: Test sidebar theming**

Start the demo app: `cd demo && mix phx.server`
- [ ] Load http://localhost:4000/docs
- [ ] Change color themes and verify sidebar background changes
- [ ] Change from light to dark mode and verify sidebar updates

- [ ] **Step 4: Commit**

```bash
git add dev/assets/docs/static_docs.js
git commit -m "fix: apply sidebar tokens to sidebar element for theme changes"
```

---

### Task 3: Final Quality Checks

**Files:**
- All modified files

- [ ] **Step 1: Run tests**

```bash
cd demo && mix test
```
Expected: All tests pass

- [ ] **Step 2: Run quality checks**

```bash
mix quality
```
Expected: All checks pass

- [ ] **Step 3: Verify visually**

- [ ] Load http://localhost:4000/docs
- [ ] Test all 7 color themes (Neutral, Stone, Zinc, Mauve, Olive, Mist, Taupe)
- [ ] For each theme, verify:
  - [ ] Main content colors update
  - [ ] Sidebar background updates
  - [ ] Light/dark mode toggle works
- [ ] Commit if needed

```bash
git add -A
git commit -m "chore: final cleanup after theme system fixes"
```

---

## Summary

3 tasks total:
1. Update theme presets to match shadcn UI official colors (Neutral, Stone, Zinc, Mauve, Olive, Mist, Taupe)
2. Fix sidebar theming to respond to color changes
3. Final quality checks and visual verification

Total estimated time: 1-2 hours.
