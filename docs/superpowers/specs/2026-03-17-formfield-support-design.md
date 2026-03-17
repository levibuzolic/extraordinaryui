# FormField Support for CinderUI Form Components

## Problem

CinderUI form components (`input/1`, `textarea/1`, `checkbox/1`, etc.) accept raw attributes (`id`, `name`, `value`) but do not accept `Phoenix.HTML.FormField` structs. Every Phoenix app uses `field={@form[:name]}` in templates, making CinderUI form components incompatible without a wrapper.

## Decision

Add a `field` attr directly to each form primitive. When provided, the component extracts `id`, `name`, `value`, and `errors` from the FormField struct and renders an optional label and error messages. This matches what Phoenix developers expect and keeps call sites minimal.

## Components Affected

All form components:

- `input/1`
- `textarea/1`
- `checkbox/1`
- `switch/1`
- `native_select/1`
- `select/1`
- `autocomplete/1`
- `radio_group/1`
- `slider/1`
- `number_field/1`

## New Attrs

Each component gains these attrs:

| Attr | Type | Default | Description |
|------|------|---------|-------------|
| `field` | `Phoenix.HTML.FormField` | `nil` | Extracts `id`, `name`, `value`, and errors from the form field |
| `label` | `string` | `nil` | Renders a `<.label>` above the control |
| `errors` | `list(string)` | `[]` | Pre-translated error strings; overrides auto-extracted errors when non-empty |

## Behaviour

### FormField Unwrapping

When `field` is provided:

1. Extract `id`, `name`, `value` from the struct (using `assign_new` so explicit attrs take precedence).
2. If `errors` attr is empty, auto-extract errors from `field.errors` using `Phoenix.Component.used_input?/1` (errors only appear after user interaction).
3. Translate `{msg, opts}` error tuples using standard string interpolation (no Gettext dependency).

### Label Rendering

When `label` is provided, render a `<.label>` element above the control with `for` pointing to the input's `id`.

### Error Rendering

When translated errors exist (either auto-extracted or explicitly passed), render `<.field_error>` elements below the control.

### Wrapping

When `label` or errors are present, the component wraps in a container `<div>`. When neither is present (raw mode), it renders just the bare control element.

### Precedence

- Explicit `id`, `name`, `value` attrs override values from `field`.
- Explicit `errors` attr overrides auto-extracted errors from `field`.
- `label` is independent of `field` (can be used with or without it).

## Error Translation

Hardcoded inside CinderUI. No Gettext dependency. Covers the standard Phoenix error format:

```elixir
defp translate_error({msg, opts}) do
  Enum.reduce(opts, msg, fn {key, value}, acc ->
    String.replace(acc, "%{#{key}}", to_string(value))
  end)
end
```

Apps needing custom translation (e.g., Gettext) can pass pre-translated strings via the `errors` attr.

## Internal Implementation

A shared helper function handles FormField unwrapping to avoid duplication across 10 components. Located in `CinderUI.Helpers` or as a private function within `CinderUI.Components.Forms`:

```elixir
defp unwrap_field(assigns) do
  case assigns[:field] do
    %Phoenix.HTML.FormField{} = field ->
      raw_errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
      translated = Enum.map(raw_errors, &translate_error/1)

      assigns
      |> assign(:field, nil)
      |> assign_new(:id, fn -> field.id end)
      |> assign_new(:name, fn -> field.name end)
      |> assign_new(:value, fn -> field.value end)
      |> maybe_put_errors(translated)

    _ ->
      assigns
  end
end
```

Where `maybe_put_errors/2` only sets errors if the caller didn't pass explicit ones.

## No Type Dispatch

`input/1` does not dispatch to other components based on `type`. Each component is called directly:

- `<.input type="textarea">` is not supported; use `<.textarea>` instead
- `<.input type="checkbox">` is not supported; use `<.checkbox>` instead
- `<.input type="select">` is not supported; use `<.native_select>` instead

## Doc Blocks

Each component's `@doc` must include examples for:

1. **Raw mode** — no `field`, just explicit attrs
2. **With `field`** — FormField wiring with auto errors
3. **With `field` + `label`** — label + control + errors
4. **With explicit `errors`** — overriding auto-extracted errors
5. **Inside `<.field>` composition** — for complex layouts with descriptions, custom labels

## Checkbox / Switch Specifics

For boolean fields (`checkbox/1`, `switch/1`):

- Extract `checked` from `field.value` using `Phoenix.HTML.Form.normalize_value("checkbox", value)`.
- Render a hidden input with `value="false"` before the checkbox (standard Phoenix pattern for unchecked submission).
- The `name` attr gets `[]` suffix when `multiple` is true.

## Native Select Specifics

- Currently uses `:option` slots. With `field`, also accept an `options` attr (list compatible with `Phoenix.HTML.Form.options_for_select/2`) as a convenience alongside the slot-based API.
- `value` from the FormField determines which option is selected.

## Migration from CoreComponents

| CoreComponents | CinderUI |
|----------------|----------|
| `<.input field={f[:name]} label="Name" />` | `<.input field={f[:name]} label="Name" />` (same) |
| `<.input field={f[:notes]} type="textarea" label="Notes" />` | `<.textarea field={f[:notes]} label="Notes" />` |
| `<.input field={f[:online]} type="checkbox" />` | `<.checkbox field={f[:online]} />` |
| `<.input field={f[:role]} type="select" options={opts} />` | `<.native_select field={f[:role]} options={opts} />` |
| `<.input type="hidden" name="id" value={@id} />` | `<input type="hidden" name="id" value={@id} />` (raw HTML) |
