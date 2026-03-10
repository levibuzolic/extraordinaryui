# Modal Focus Management via `inert`

## Summary

Add `inert` attribute management to modal overlay components (Dialog, Alert Dialog, Drawer, Sheet) so that background content is natively inaccessible while a modal is open.

## Scope

**In scope:** Dialog, Alert Dialog, Drawer, Sheet.

**Out of scope:** Popover, Dropdown Menu (non-modal — users should still interact with the page).

## Behavior

### On open

1. Walk up from the overlay element to find sibling elements at the top level.
2. Set `inert` on each sibling that is not already inert.
3. Track which elements were inerted so removal is precise.
4. Focus moves to the first focusable element inside the content (already implemented).

### On close

1. Remove `inert` from all elements that were inerted during open.
2. Do not un-inert elements that were already inert before the modal opened.
3. Restore focus to the previously active element (already implemented).

## Implementation

### Shared helpers

Add `applyInert(overlayEl)` and `removeInert()` to the existing hook utility functions in `cinder_ui.js`. These manage a stored list of inerted elements so cleanup is precise.

### Hook integration

- `CuiDialog`: call `applyInert` on open, `removeInert` on close.
- `createPanelHook` (used by Drawer and Sheet): same integration.
- Alert Dialog: delegates to Dialog, inherits behavior automatically.

### What stays the same

- Escape key, outside click, close button dismissal — unchanged.
- Focus restoration — already works.
- Command model — unchanged.
- Server-controlled open state — unchanged.

## Testing

Add browser tests verifying:

- Background elements receive `inert` when a modal opens.
- Background elements lose `inert` when the modal closes.
- Elements that were already `inert` before the modal opened remain `inert` after close.
- Tab key cannot reach background elements while a modal is open.

## Browser support

`inert` is supported in all major browsers since early 2023 (Chrome 102, Firefox 112, Safari 15.5). No polyfill or fallback needed.
