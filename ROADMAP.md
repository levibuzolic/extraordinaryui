# Cinder UI Roadmap

Task list for AI agents working on improving the library.
Items are grouped by priority and category.

---

## High Priority

### Accessibility

- [ ] **Tabs: add ARIA tab pattern** — `navigation.ex` tabs component needs `role="tablist"` on list, `role="tab"` on triggers, `role="tabpanel"` on content, `aria-selected` on active trigger
- [ ] **Dialog/Sheet/Drawer: add aria-labelledby/describedby** — `overlay.ex` dialog has `role="dialog"` but no `aria-labelledby` pointing at the title or `aria-describedby` pointing at the description
- [ ] **Dropdown menu: add menu roles** — `overlay.ex` dropdown needs `role="menu"` on content, `role="menuitem"` on items
- [ ] **Tooltip: add role and aria-describedby** — `overlay.ex` tooltip needs `role="tooltip"`, an `id`, and trigger must reference it via `aria-describedby`
- [ ] **Autocomplete: add role="combobox"** — `forms.ex` autocomplete input is missing `role="combobox"` per WAI-ARIA pattern
- [ ] **Carousel: add aria-labels** — `advanced.ex` prev/next buttons need `aria-label`, root needs `aria-roledescription="carousel"`
- [ ] **Hover card: add keyboard support** — `overlay.ex` hover_card uses only `group-hover:block`, needs `group-focus-within:block` for keyboard users
- [ ] **Consistent aria-label casing** — Standardize `aria-label="Close"` (capitalized) across flash and dialog close buttons

### Flash / Alert alignment

- [ ] **Rework flash to use alert/1 internally** — Flash currently uses its own flex layout (see TODO in `feedback.ex`). Resolve the alert grid vertical alignment issues and share the layout between flash and alert
- [ ] **Add :success and :warning flash kinds** — Only `:info` and `:error` exist. Real apps commonly need `:success` and `:warning`
- [ ] **Add :success and :warning alert variants** — Only `:default` and `:destructive` exist

### Forms

- [ ] **field_control invalid state: cover all controls** — `forms.ex` `field_control/1` cascades invalid styling to `input`, `textarea`, `select-trigger`, `autocomplete-input` but misses `native-select`, `combobox-input`, `switch`, `checkbox`, `radio-group-item`
- [ ] **Input: add min/max to rest includes** — `forms.ex` input `@rest` include list omits `min` and `max`, needed for number/date inputs
- [ ] **Slider: support float values** — `forms.ex` slider uses `attr :value, :integer`, should accept floats
- [ ] **Radio group: add per-option disabled** — `forms.ex` radio_group option slot lacks a `disabled` attribute
- [ ] **Input OTP: implement JS hook** — No `CuiInputOtp` hook exists. Auto-advance focus on input and backspace-to-previous are unimplemented
- [ ] **Input OTP: add separator support** — shadcn supports visual separators between digit groups

---

## Medium Priority

### Missing JS Hooks

- [ ] **Menubar: implement JS hook** — `overlay.ex` menubar has no JS hook at all, relies only on CSS hover. Needs keyboard arrow navigation and click-to-open
- [ ] **Autocomplete: add Home/End key support** — `CuiSelect` handles Home/End but `CuiAutocomplete` does not
- [ ] **Select/Dropdown: add typeahead search** — Pressing a letter key should jump to matching items (WAI-ARIA listbox pattern)

### Component Improvements

- [ ] **Avatar: add image error fallback** — When `@src` 404s, the `<img>` shows as broken. Add `onerror` handling to fall back to initials
- [ ] **Avatar group count: support size prop** — `data_display.ex` `avatar_group_count/1` is hardcoded to `size-8`, should respect avatar group size
- [ ] **Code block: add copy button** — `data_display.ex` code_block has a `relative` wrapper but no copy-to-clipboard button
- [ ] **Sidebar: use sidebar CSS variables** — `advanced.ex` sidebar uses `bg-muted/20` inline instead of the `--sidebar` CSS variables defined in `cinder_ui.css`
- [ ] **Button group: merge borders** — shadcn merges inner borders between adjacent buttons with negative margin. CinderUI just uses `gap-2`
- [ ] **Popover/dropdown: viewport-aware positioning** — Hardcoded `mt-2` below trigger. Add a JS-based placement system for edge-of-viewport handling
- [ ] **Carousel: add autoplay, loop, and indicators** — Hook only does prev/next. No autoplay interval, pause-on-hover, or dot indicators

### Code Quality

- [ ] **Unify HEEx syntax** — Some files still use `<%= %>` (overlay.ex lines 586-614, layout.ex lines 614-676, navigation.ex lines 544-553, data_display.ex line 647). Convert to `{}` syntax everywhere
- [ ] **Remove redundant disabled class in dropdown_menu** — `overlay.ex` items apply both `disabled` HTML attr and manual opacity class. The HTML attr already triggers Tailwind disabled: utilities
- [ ] **Remove dead switch thumb_position case** — `forms.ex` lines 459-463 both `:sm` and `:default` return the same value

### CSS

- [ ] **Reconcile dark mode systems** — `cinder_ui.css` defines `@custom-variant dark` for `[data-theme=dark]` but CSS variables only switch under `.dark` class. These need to be consistent
- [ ] **Map chart/sidebar CSS vars to Tailwind** — `--chart-1` through `--chart-5` and `--sidebar-*` variables exist but aren't in `@theme inline`, so `bg-chart-1` etc. don't work as utilities
- [ ] **Add prefers-reduced-motion overrides** — Animation classes from tailwindcss-animate have no reduced-motion consideration (except flash spinner)

---

## Low Priority

### Missing Components

- [ ] **Context Menu** — Right-click context menu (significant JS required)
- [ ] **Toast/Sonner** — Stacking toast notifications (intentionally deferred)
- [ ] **Date Picker** — Combine Calendar + Popover with date selection logic
- [ ] **Data Table** — Compose table/1 with sorting, filtering, pagination
- [ ] **Number Field** — Increment/decrement input
- [ ] **File Upload / Dropzone** — Styled drop zone for Phoenix `allow_upload/3`
- [ ] **Stepper** — Multi-step progress indicator for wizards

### Calendar

- [ ] **Implement date selection logic** — Currently just a styled container. Needs week/month navigation, single/range/multi select, server state integration

### Testing

- [ ] **Expand component unit tests** — Most tests only check `data-slot` presence. Missing structural assertions for: button_group, toggle_group, accordion, collapsible, code_block, avatar_group, popover, tooltip, hover_card, alert_dialog, menubar, pagination, combobox, carousel, chart, sidebar, checkbox, radio_group, slider, input_otp, label, field_label, field_description, field_message
- [ ] **Add LiveView integration tests** — No tests exercise hook interactions (open/close dialog, select options, autocomplete filtering)
- [ ] **Add JS hook tests** — Zero automated tests for client-side behavior

### Install Task

- [ ] **Detect `bun.lock` (text format)** — `lib/mix/tasks/cinder_ui.install.ex` line 258 only checks `bun.lockb` (binary). Bun v1.1+ uses `bun.lock`
- [ ] **Handle inline Hooks in app.js** — `inject_hooks_merge/1` doesn't handle `const liveSocket = new LiveSocket(...)` with Hooks defined inline
- [ ] **Add --dry-run option** — Let users preview install changes without writing files

### Documentation

- [ ] **Clarify combobox vs autocomplete** — Add "when to use which" guidance to both component docs
- [ ] **Fix select README description** — README says "native select style variant" which describes native_select, not select
- [ ] **Update resizable status** — Either promote from "In Progress" or document what's specifically incomplete
