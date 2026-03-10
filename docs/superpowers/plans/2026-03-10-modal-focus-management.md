# Modal Focus Management Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `inert` attribute management to modal overlay components so background content is inaccessible while a modal is open.

**Architecture:** Two shared helper functions (`applyInert` / `removeInert`) added to the existing hook utilities. Called from `CuiDialog.sync()` and `createPanelHook.sync()` (which covers Drawer and Sheet). The helpers track which elements were inerted to avoid incorrectly un-inerting pre-existing inert elements.

**Tech Stack:** JavaScript (LiveView hooks), Playwright (browser tests)

---

## File Map

- **Modify:** `priv/templates/cinder_ui.js` — add inert helpers and integrate into CuiDialog + createPanelHook
- **Modify:** `assets/js/cinder_ui.js` — mirror inert helpers into the simplified demo hooks (CuiDialog, CuiDrawer only — no createPanelHook in this file)
- **Modify:** `demo/tests/browser/interactions.spec.ts` — add browser tests for inert behavior
- **Modify:** `docs/competitive-audit-roadmap.md` — mark 2.2 focus management as complete

---

### Task 1: Add inert helper functions to priv/templates/cinder_ui.js

**Files:**
- Modify: `priv/templates/cinder_ui.js:56-85` (after existing focus helpers, before CuiDialog)

- [ ] **Step 1: Add `applyInert` and `removeInert` helpers**

Add these two functions after the `restoreFocus` function (line 85) and before `CuiDialog` (line 87):

```javascript
const applyInert = (overlayEl) => {
  const inertedElements = []
  let current = overlayEl

  while (current && current !== document.body) {
    const parent = current.parentElement
    if (parent) {
      for (const sibling of parent.children) {
        if (sibling !== current && !sibling.inert) {
          sibling.inert = true
          inertedElements.push(sibling)
        }
      }
    }
    current = parent
  }

  return inertedElements
}

const removeInert = (inertedElements) => {
  if (!inertedElements) return
  for (const el of inertedElements) {
    el.inert = false
  }
}
```

- [ ] **Step 2: Verify the file still has valid syntax**

Run: `cd demo && npx esbuild ../priv/templates/cinder_ui.js --bundle --format=esm --outfile=/dev/null 2>&1; cd ..`
Expected: No errors

- [ ] **Step 3: Commit**

```
git add priv/templates/cinder_ui.js
git commit -m "Add applyInert/removeInert helper functions for modal focus management"
```

---

### Task 2: Integrate inert into CuiDialog

**Files:**
- Modify: `priv/templates/cinder_ui.js` — CuiDialog hook (lines 87-155)

- [ ] **Step 1: Initialize inertedElements in mounted()**

In `CuiDialog.mounted()`, after `this.lastActiveElement = null` (line 95), add:

```javascript
this.inertedElements = null
```

- [ ] **Step 2: Apply inert on open, remove on close in sync()**

In `CuiDialog.sync()`, after `toggleVisibility(this.content, open)` (line 139), add inert management:

```javascript
if (open && !wasOpen) {
  this.inertedElements = applyInert(this.el)
}

if (!open && wasOpen) {
  removeInert(this.inertedElements)
  this.inertedElements = null
}
```

- [ ] **Step 3: Clean up inert on destroyed()**

In `CuiDialog.destroyed()`, before the closing brace, add:

```javascript
removeInert(this.inertedElements)
```

- [ ] **Step 4: Verify syntax**

Run: `cd demo && npx esbuild ../priv/templates/cinder_ui.js --bundle --format=esm --outfile=/dev/null 2>&1; cd ..`
Expected: No errors

- [ ] **Step 5: Commit**

```
git add priv/templates/cinder_ui.js
git commit -m "Add inert attribute management to CuiDialog"
```

---

### Task 3: Integrate inert into createPanelHook (Drawer + Sheet)

**Files:**
- Modify: `priv/templates/cinder_ui.js` — createPanelHook (lines 157-225)

- [ ] **Step 1: Initialize inertedElements in mounted()**

In `createPanelHook`, inside `mounted()`, after `this.lastActiveElement = null` (line 165), add:

```javascript
this.inertedElements = null
```

- [ ] **Step 2: Apply inert on open, remove on close in sync()**

In `createPanelHook.sync()`, after `toggleVisibility(this.content, open)` (line 209), add:

```javascript
if (open && !wasOpen) {
  this.inertedElements = applyInert(this.el)
}

if (!open && wasOpen) {
  removeInert(this.inertedElements)
  this.inertedElements = null
}
```

- [ ] **Step 3: Clean up inert on destroyed()**

In `createPanelHook.destroyed()`, before the closing brace, add:

```javascript
removeInert(this.inertedElements)
```

- [ ] **Step 4: Verify syntax**

Run: `cd demo && npx esbuild ../priv/templates/cinder_ui.js --bundle --format=esm --outfile=/dev/null 2>&1; cd ..`
Expected: No errors

- [ ] **Step 5: Commit**

```
git add priv/templates/cinder_ui.js
git commit -m "Add inert attribute management to Drawer and Sheet via createPanelHook"
```

---

### Task 4: Mirror changes to assets/js/cinder_ui.js

The demo app uses a simplified copy of the hooks. It has `CuiDialog` and `CuiDrawer` as standalone hooks (no `createPanelHook`).

**Files:**
- Modify: `assets/js/cinder_ui.js`

- [ ] **Step 1: Add applyInert/removeInert helpers**

Add the same `applyInert` and `removeInert` functions after the `normalizePercentages` function (line 26), before `CuiDialog` (line 28).

- [ ] **Step 2: Add inert to CuiDialog**

In `CuiDialog.mounted()`, initialize `this.inertedElements = null`.

In `CuiDialog.sync()`, after `toggleVisibility(this.el.querySelector("[data-dialog-content]"), open)`:

```javascript
if (open) {
  this.inertedElements = applyInert(this.el)
} else {
  removeInert(this.inertedElements)
  this.inertedElements = null
}
```

Note: the simplified CuiDialog doesn't track wasOpen, so use open/!open directly.

In `CuiDialog.destroyed()`, add `removeInert(this.inertedElements)`.

- [ ] **Step 3: Add inert to CuiDrawer**

Same pattern as CuiDialog — initialize in mounted, apply/remove in sync, clean up in destroyed.

- [ ] **Step 4: Verify syntax**

Run: `cd demo && npx esbuild ../assets/js/cinder_ui.js --bundle --format=esm --outfile=/dev/null 2>&1; cd ..`
Expected: No errors

- [ ] **Step 5: Commit**

```
git add assets/js/cinder_ui.js
git commit -m "Mirror inert attribute management to simplified demo hooks"
```

---

### Task 5: Add browser tests for inert behavior

**Files:**
- Modify: `demo/tests/browser/interactions.spec.ts`

- [ ] **Step 1: Add test — dialog applies inert to siblings when open**

Add inside the `"interactive previews"` describe block:

```typescript
test("dialog applies inert to background when open", async ({ page }) => {
  const root = page.locator("[data-slot='dialog']").first()
  const trigger = root.locator("[data-dialog-trigger]")

  await root.scrollIntoViewIfNeeded()
  await trigger.click()

  const hasInertSiblings = await root.evaluate((el) => {
    let current: Element | null = el
    while (current && current !== document.body) {
      const parent = current.parentElement
      if (parent) {
        for (const sibling of Array.from(parent.children)) {
          if (sibling !== current && sibling instanceof HTMLElement && sibling.inert) {
            return true
          }
        }
      }
      current = parent
    }
    return false
  })

  expect(hasInertSiblings).toBe(true)

  await page.keyboard.press("Escape")

  const hasInertAfterClose = await root.evaluate((el) => {
    let current: Element | null = el
    while (current && current !== document.body) {
      const parent = current.parentElement
      if (parent) {
        for (const sibling of Array.from(parent.children)) {
          if (sibling !== current && sibling instanceof HTMLElement && sibling.inert) {
            return true
          }
        }
      }
      current = parent
    }
    return false
  })

  expect(hasInertAfterClose).toBe(false)
})
```

- [ ] **Step 2: Add test — drawer applies inert to background when open**

```typescript
test("drawer applies inert to background when open", async ({ page }) => {
  const root = page.locator("[data-slot='drawer']").first()
  const trigger = root.locator("[data-drawer-trigger]")

  await root.scrollIntoViewIfNeeded()
  await trigger.click()

  const hasInertSiblings = await root.evaluate((el) => {
    let current: Element | null = el
    while (current && current !== document.body) {
      const parent = current.parentElement
      if (parent) {
        for (const sibling of Array.from(parent.children)) {
          if (sibling !== current && sibling instanceof HTMLElement && sibling.inert) {
            return true
          }
        }
      }
      current = parent
    }
    return false
  })

  expect(hasInertSiblings).toBe(true)

  await page.keyboard.press("Escape")

  const hasInertAfterClose = await root.evaluate((el) => {
    let current: Element | null = el
    while (current && current !== document.body) {
      const parent = current.parentElement
      if (parent) {
        for (const sibling of Array.from(parent.children)) {
          if (sibling !== current && sibling instanceof HTMLElement && sibling.inert) {
            return true
          }
        }
      }
      current = parent
    }
    return false
  })

  expect(hasInertAfterClose).toBe(false)
})
```

- [ ] **Step 3: Add test — pre-existing inert elements are preserved**

```typescript
test("pre-existing inert elements stay inert after modal closes", async ({ page }) => {
  const root = page.locator("[data-slot='dialog']").first()
  const trigger = root.locator("[data-dialog-trigger]")

  await root.scrollIntoViewIfNeeded()

  // Mark an arbitrary element as inert before opening
  await page.evaluate(() => {
    const footer = document.querySelector("footer")
    if (footer) (footer as HTMLElement).inert = true
  })

  await trigger.click()
  await page.keyboard.press("Escape")

  const footerStillInert = await page.evaluate(() => {
    const footer = document.querySelector("footer")
    return footer ? (footer as HTMLElement).inert : false
  })

  expect(footerStillInert).toBe(true)

  // Clean up
  await page.evaluate(() => {
    const footer = document.querySelector("footer")
    if (footer) (footer as HTMLElement).inert = false
  })
})
```

- [ ] **Step 4: Run tests**

Run: `cd demo && npx playwright test tests/browser/interactions.spec.ts --reporter=list`
Expected: All tests pass

- [ ] **Step 5: Commit**

```
git add demo/tests/browser/interactions.spec.ts
git commit -m "Add browser tests for modal inert attribute management"
```

---

### Task 6: Update roadmap

**Files:**
- Modify: `docs/competitive-audit-roadmap.md`

- [ ] **Step 1: Mark 2.2 focus management item as complete**

Change line 212:
```
- [-] Add focus management expectations for dialog-like components.
```
to:
```
- [x] Add focus management expectations for dialog-like components.
```

- [ ] **Step 2: Add progress log entry**

Add to the Progress Log section:

```markdown
### 2026-03-10

- Added `inert` attribute management to modal overlay components (Dialog, Alert Dialog, Drawer, Sheet).
- Background content is natively inaccessible while a modal is open.
- Pre-existing `inert` elements are preserved when the modal closes.
- Browser tests added for inert behavior on dialog and drawer.
```

- [ ] **Step 3: Commit**

```
git add docs/competitive-audit-roadmap.md
git commit -m "Mark Phase 2.2 focus management as complete in roadmap"
```
