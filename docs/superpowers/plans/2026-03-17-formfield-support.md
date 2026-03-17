# FormField Support Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `Phoenix.HTML.FormField` support to all CinderUI form components so they work with Phoenix forms out of the box.

**Architecture:** A shared `unwrap_field/1` helper in `CinderUI.Components.Forms` extracts `id`, `name`, `value`, and `errors` from a FormField struct. Each form component calls this helper at the top of its function body. When `label` or errors are present, the component wraps itself in a container div with `<.label>` and `<.field_error>` elements.

**Tech Stack:** Elixir, Phoenix LiveView, Phoenix.HTML.FormField, Floki (tests)

**Spec:** `docs/superpowers/specs/2026-03-17-formfield-support-design.md`

**No backwards compatibility required** — no external users yet.

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/cinder_ui/components/forms.ex` | Modify | Add `field`/`label`/`errors` attrs + wrapping logic to all 11 form components |
| `test/cinder_ui/components/forms_test.exs` | Modify | Add FormField integration tests for each component |

The shared helper (`unwrap_field/1`, `translate_error/1`) lives as private functions inside `CinderUI.Components.Forms` since they're only used by this module.

### Implementation notes

**Template duplication:** Each component renders its control twice — once inside a wrapping `<div>` (when label/errors present), once bare (when neither present). This is an accepted tradeoff. HEEx doesn't support conditional wrappers, and extracting per-component private helpers adds more complexity than the duplication.

**`errors` attr default is `nil`**, not `[]`. This allows `maybe_put_errors/2` to distinguish "caller didn't pass errors" from "caller explicitly passed empty errors". When `errors` is `nil`, auto-extracted errors from the FormField are used. When `errors` is explicitly set (even to `[]`), the explicit value takes precedence.

**`id` changes from `required: true` to `default: nil`** on components where `field` can provide it: `checkbox`, `switch`, `number_field`, `select`, `autocomplete`, `input_otp`.

---

## Chunk 1: Shared Helper + Input

### Task 1: Add shared FormField helpers

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex`

- [ ] **Step 1: Add `alias Phoenix.HTML.Form` at the top of the module (after existing aliases)**

```elixir
alias Phoenix.HTML.Form
```

- [ ] **Step 2: Add the private helper functions at the bottom of the Forms module**

Add these private functions before the final `end` of the module (before the existing `defp selected_option` and other private functions):

```elixir
# -- FormField helpers -------------------------------------------------------

defp unwrap_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  raw_errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
  translated = Enum.map(raw_errors, &translate_error/1)

  assigns
  |> assign(:field, nil)
  |> assign_new(:id, fn -> field.id end)
  |> assign_new(:name, fn -> field.name end)
  |> assign_new(:value, fn -> field.value end)
  |> maybe_put_errors(translated)
end

defp unwrap_field(assigns), do: assigns

defp maybe_put_errors(%{errors: errors} = assigns, _auto_errors) when not is_nil(errors),
  do: assigns

defp maybe_put_errors(assigns, errors), do: assign(assigns, :errors, errors)

defp translate_error({msg, opts}) do
  Enum.reduce(opts, msg, fn {key, value}, acc ->
    String.replace(acc, "%{#{key}}", to_string(value))
  end)
end
```

- [ ] **Step 3: Compile to verify no errors**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix compile`
Expected: Clean compile

- [ ] **Step 4: Commit**

```
git add lib/cinder_ui/components/forms.ex
git commit -m "feat(forms): add shared FormField unwrap helpers"
```

### Task 2: Add FormField support to `input/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 358-390)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

Add to `forms_test.exs`:

```elixir
describe "input with FormField" do
  test "extracts id, name, value from field" do
    form = Phoenix.Component.to_form(%{"name" => "Alice"}, as: :user)

    html =
      render_component(&Forms.input/1, %{
        field: form[:name]
      })

    assert TestHelpers.attr(html, "[data-slot='input']", "id") == "user_name"
    assert TestHelpers.attr(html, "[data-slot='input']", "name") == "user[name]"
    assert TestHelpers.attr(html, "[data-slot='input']", "value") == "Alice"
  end

  test "renders label when label attr is provided" do
    form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

    html =
      render_component(&Forms.input/1, %{
        field: form[:name],
        label: "Full Name"
      })

    assert TestHelpers.text(html, "[data-slot='label']") == "Full Name"
    assert TestHelpers.attr(html, "[data-slot='label']", "for") == "user_name"
  end

  test "renders errors from explicit errors attr" do
    html =
      render_component(&Forms.input/1, %{
        id: "name",
        name: "name",
        errors: ["can't be blank"]
      })

    assert TestHelpers.text(html, "[data-slot='field-error']") == "can't be blank"
  end

  test "explicit id overrides field id" do
    form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

    html =
      render_component(&Forms.input/1, %{
        field: form[:name],
        id: "custom-id"
      })

    assert TestHelpers.attr(html, "[data-slot='input']", "id") == "custom-id"
  end

  test "renders bare input when no label or errors" do
    form = Phoenix.Component.to_form(%{"name" => ""}, as: :user)

    html =
      render_component(&Forms.input/1, %{
        field: form[:name]
      })

    refute html =~ "data-slot=\"label\""
    refute html =~ "data-slot=\"field-error\""
  end

  test "translates error tuples from field errors" do
    # Simulate a form field with errors by passing explicit translated errors
    html =
      render_component(&Forms.input/1, %{
        id: "count",
        name: "count",
        errors: ["must be at least 3"]
      })

    assert TestHelpers.text(html, "[data-slot='field-error']") == "must be at least 3"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix test test/cinder_ui/components/forms_test.exs --trace`
Expected: Failures (unknown attr `field`)

- [ ] **Step 3: Update `input/1` attrs and function body**

Replace the current `input/1` attr declarations and function (around line 358-390) with:

```elixir
attr :id, :string, default: nil
attr :type, :string, default: "text"
attr :name, :string, default: nil
attr :value, :string, default: nil
attr :field, Phoenix.HTML.FormField, default: nil
attr :label, :string, default: nil
attr :errors, :list, default: nil
attr :placeholder, :string, default: nil
attr :class, :string, default: nil

attr :rest, :global,
  include:
    ~w(accept autocomplete disabled max maxlength min minlength pattern readonly required step)

def input(assigns) do
  assigns =
    assigns
    |> unwrap_field()
    |> assign_new(:errors, fn -> [] end)
    |> assign(:input_classes, [
      "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
      "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
      "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
      assigns.class
    ])

  ~H"""
  <div :if={@label || @errors != []} class="space-y-2">
    <.label :if={@label} for={@id}>{@label}</.label>
    <input
      id={@id}
      type={@type}
      data-slot="input"
      name={@name}
      value={@value}
      placeholder={@placeholder}
      class={classes(@input_classes)}
      {@rest}
    />
    <.field_error :for={msg <- @errors}>{msg}</.field_error>
  </div>
  <input
    :if={!@label && @errors == []}
    id={@id}
    type={@type}
    data-slot="input"
    name={@name}
    value={@value}
    placeholder={@placeholder}
    class={classes(@input_classes)}
    {@rest}
  />
  """
end
```

Key: `errors` defaults to `nil`, then `assign_new(:errors, fn -> [] end)` sets it to `[]` only if `unwrap_field` didn't already set it. This lets `maybe_put_errors` distinguish explicit from default.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix test test/cinder_ui/components/forms_test.exs --trace`
Expected: All pass

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to input/1"
```

---

## Chunk 2: Textarea + Checkbox + Switch

### Task 3: Add FormField support to `textarea/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 508-540)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

```elixir
describe "textarea with FormField" do
  test "extracts id, name, value from field" do
    form = Phoenix.Component.to_form(%{"notes" => "hello"}, as: :item)

    html =
      render_component(&Forms.textarea/1, %{
        field: form[:notes]
      })

    assert TestHelpers.attr(html, "[data-slot='textarea']", "id") == "item_notes"
    assert TestHelpers.attr(html, "[data-slot='textarea']", "name") == "item[notes]"
    assert html =~ "hello"
  end

  test "renders label and errors" do
    html =
      render_component(&Forms.textarea/1, %{
        id: "notes",
        name: "notes",
        label: "Notes",
        errors: ["too short"]
      })

    assert TestHelpers.text(html, "[data-slot='label']") == "Notes"
    assert TestHelpers.text(html, "[data-slot='field-error']") == "too short"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix test test/cinder_ui/components/forms_test.exs --trace`

- [ ] **Step 3: Update `textarea/1` attrs and function body**

Same pattern as `input/1`: add `field`, `label`, `errors` (default `nil`) attrs. Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`. Duplicate template with `:if` guard for wrapping.

```elixir
attr :id, :string, default: nil
attr :name, :string, default: nil
attr :value, :string, default: nil
attr :field, Phoenix.HTML.FormField, default: nil
attr :label, :string, default: nil
attr :errors, :list, default: nil
attr :placeholder, :string, default: nil
attr :rows, :integer, default: 4
attr :class, :string, default: nil
attr :rest, :global, include: ~w(disabled maxlength minlength readonly required)

def textarea(assigns) do
  assigns =
    assigns
    |> unwrap_field()
    |> assign_new(:errors, fn -> [] end)
    |> assign(:textarea_classes, [
      "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
      assigns.class
    ])

  ~H"""
  <div :if={@label || @errors != []} class="space-y-2">
    <.label :if={@label} for={@id}>{@label}</.label>
    <textarea
      id={@id}
      data-slot="textarea"
      name={@name}
      placeholder={@placeholder}
      rows={@rows}
      class={classes(@textarea_classes)}
      {@rest}
    >{@value}</textarea>
    <.field_error :for={msg <- @errors}>{msg}</.field_error>
  </div>
  <textarea
    :if={!@label && @errors == []}
    id={@id}
    data-slot="textarea"
    name={@name}
    placeholder={@placeholder}
    rows={@rows}
    class={classes(@textarea_classes)}
    {@rest}
  >{@value}</textarea>
  """
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix test test/cinder_ui/components/forms_test.exs --trace`

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to textarea/1"
```

### Task 4: Add FormField support to `checkbox/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 548-582)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

```elixir
describe "checkbox with FormField" do
  test "extracts checked state from field value" do
    form = Phoenix.Component.to_form(%{"online" => true}, as: :store)

    html =
      render_component(&Forms.checkbox/1, %{
        field: form[:online]
      })

    assert TestHelpers.attr(html, "[data-slot='checkbox']", "id") == "store_online"
    assert TestHelpers.attr(html, "[data-slot='checkbox']", "name") == "store[online]"
    assert TestHelpers.attr(html, "[data-slot='checkbox']", "checked") == "checked"
  end

  test "renders hidden input for unchecked submission" do
    form = Phoenix.Component.to_form(%{"active" => false}, as: :item)

    html =
      render_component(&Forms.checkbox/1, %{
        field: form[:active]
      })

    assert TestHelpers.attr(html, "input[type='hidden']", "name") == "item[active]"
    assert TestHelpers.attr(html, "input[type='hidden']", "value") == "false"
  end

  test "renders label from label attr inline" do
    form = Phoenix.Component.to_form(%{"online" => false}, as: :store)

    html =
      render_component(&Forms.checkbox/1, %{
        field: form[:online],
        label: "Online"
      })

    assert html =~ "Online"
  end

  test "inner_block takes precedence over label attr" do
    html =
      render_component(&Forms.checkbox/1, %{
        id: "terms",
        name: "terms",
        label: "Fallback",
        inner_block: CinderUI.TestHelpers.slot("Accept Terms")
      })

    assert html =~ "Accept Terms"
    refute html =~ "Fallback"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

- [ ] **Step 3: Update `checkbox/1`**

Key changes:
- Change `id` from `required: true` to `default: nil`
- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()`, then extract `checked` via `Form.normalize_value("checkbox", value)`
- Add hidden input for unchecked submission when `name` is present
- `inner_block` takes precedence over `label` attr for inline label text
- Checkbox wrapping: always uses `<label>` wrapper for the inline pattern. `<div>` wrapping only added when errors present.

```elixir
attr :id, :string, default: nil
attr :name, :string, default: nil
attr :value, :string, default: "true"
attr :checked, :boolean, default: false
attr :disabled, :boolean, default: false
attr :field, Phoenix.HTML.FormField, default: nil
attr :label, :string, default: nil
attr :errors, :list, default: nil
attr :class, :string, default: nil
attr :rest, :global
slot :inner_block

def checkbox(assigns) do
  assigns =
    assigns
    |> unwrap_field()
    |> assign_new(:errors, fn -> [] end)

  assigns =
    assigns
    |> assign_new(:checked, fn ->
      Form.normalize_value("checkbox", assigns[:value])
    end)
    |> assign(:classes, [
      "peer border-input dark:bg-input/30 checked:bg-primary checked:text-primary-foreground checked:border-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive size-4 shrink-0 rounded-[4px] border shadow-xs transition-shadow outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50",
      assigns.class
    ])

  ~H"""
  <div :if={@errors != []} class="space-y-2">
    <label class="inline-flex items-center gap-2">
      <input :if={@name} type="hidden" name={@name} value="false" disabled={@disabled} />
      <input
        id={@id}
        data-slot="checkbox"
        type="checkbox"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        class={classes(@classes)}
        {@rest}
      />
      <span :if={@inner_block != []} class="text-sm text-foreground">
        {render_slot(@inner_block)}
      </span>
      <span :if={@inner_block == [] && @label} class="text-sm text-foreground">{@label}</span>
    </label>
    <.field_error :for={msg <- @errors}>{msg}</.field_error>
  </div>
  <label :if={@errors == []} class="inline-flex items-center gap-2">
    <input :if={@name} type="hidden" name={@name} value="false" disabled={@disabled} />
    <input
      id={@id}
      data-slot="checkbox"
      type="checkbox"
      name={@name}
      value={@value}
      checked={@checked}
      disabled={@disabled}
      class={classes(@classes)}
      {@rest}
    />
    <span :if={@inner_block != []} class="text-sm text-foreground">
      {render_slot(@inner_block)}
    </span>
    <span :if={@inner_block == [] && @label} class="text-sm text-foreground">{@label}</span>
  </label>
  """
end
```

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to checkbox/1"
```

### Task 5: Add FormField support to `switch/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 598-668)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

```elixir
describe "switch with FormField" do
  test "extracts checked state from field" do
    form = Phoenix.Component.to_form(%{"notifications" => true}, as: :prefs)

    html =
      render_component(&Forms.switch/1, %{
        field: form[:notifications]
      })

    assert TestHelpers.attr(html, "[data-slot='switch']", "data-state") == "checked"
    assert TestHelpers.attr(html, "[data-slot='switch']", "name") == "prefs[notifications]"
  end

  test "renders label from label attr inline" do
    form = Phoenix.Component.to_form(%{"notify" => false}, as: :prefs)

    html =
      render_component(&Forms.switch/1, %{
        field: form[:notify],
        label: "Notifications"
      })

    assert html =~ "Notifications"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

- [ ] **Step 3: Update `switch/1`**

Same pattern as checkbox:
- Change `id` from `required: true` to `default: nil`
- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()`, then `assign_new(:errors, fn -> [] end)`
- Extract `checked` via `Form.normalize_value("checkbox", value)`
- Add hidden input for unchecked submission
- `inner_block` takes precedence over `label` attr for inline text
- Wrap with `<div>` for errors only (switch label is inline like checkbox)

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to switch/1"
```

---

## Chunk 3: Native Select + Select + Autocomplete

### Task 6: Add FormField support to `native_select/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 898-934)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

```elixir
describe "native_select with FormField" do
  test "extracts id, name, value from field and renders options from options attr" do
    form = Phoenix.Component.to_form(%{"role" => "admin"}, as: :user)

    html =
      render_component(&Forms.native_select/1, %{
        field: form[:role],
        options: [{"User", "user"}, {"Admin", "admin"}]
      })

    assert TestHelpers.attr(html, "[data-slot='native-select']", "id") == "user_role"
    assert TestHelpers.attr(html, "[data-slot='native-select']", "name") == "user[role]"
    assert TestHelpers.find_all(html, "option") |> length() == 2
  end

  test "renders label and errors" do
    html =
      render_component(&Forms.native_select/1, %{
        id: "role",
        name: "role",
        label: "Role",
        errors: ["is invalid"],
        options: [{"User", "user"}]
      })

    assert TestHelpers.text(html, "[data-slot='label']") == "Role"
    assert TestHelpers.text(html, "[data-slot='field-error']") == "is invalid"
  end

  test "option slots take precedence over options attr" do
    html =
      render_component(&Forms.native_select/1, %{
        id: "role",
        name: "role",
        value: "admin",
        options: [{"Ignored", "ignored"}],
        option: [
          %{value: "admin", label: "Admin", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.find_all(html, "option") |> length() == 1
    refute html =~ "Ignored"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

- [ ] **Step 3: Update `native_select/1`**

Key changes:
- Add `id`, `field`, `label`, `errors` (default `nil`), `options` (default `nil`) attrs
- Change `:option` slot from `required: true` to optional
- Render `id` on the `<select>` element
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- When `:option` slots are provided, use slots. Otherwise fall back to `options` attr rendered via `Phoenix.HTML.Form.options_for_select/2`
- Wrap with label/errors div when present

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to native_select/1"
```

### Task 7: Add FormField support to `select/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 700-800)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing test**

```elixir
describe "select with FormField" do
  test "extracts name and value from field" do
    form = Phoenix.Component.to_form(%{"role" => "admin"}, as: :user)

    html =
      render_component(&Forms.select/1, %{
        field: form[:role],
        option: [
          %{value: "user", label: "User", inner_block: fn -> "" end},
          %{value: "admin", label: "Admin", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='select-input']", "name") == "user[role]"
    assert TestHelpers.attr(html, "[data-slot='select-input']", "value") == "admin"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `select/1`**

- Change `id` from `required: true` to `default: nil` (generate a unique default in function body if nil, as select requires an id for the JS hook)
- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- Wrap with label/errors div when present

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to select/1"
```

### Task 8: Add FormField support to `autocomplete/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 1011)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing test**

```elixir
describe "autocomplete with FormField" do
  test "extracts name and value from field" do
    form = Phoenix.Component.to_form(%{"owner" => "levi"}, as: :project)

    html =
      render_component(&Forms.autocomplete/1, %{
        field: form[:owner],
        option: [
          %{value: "levi", label: "Levi", inner_block: fn -> "" end}
        ]
      })

    assert TestHelpers.attr(html, "[data-slot='autocomplete-input']", "name") == "project[owner]"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `autocomplete/1`**

- Change `id` from `required: true` to `default: nil` (generate unique default if nil)
- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- Wrap with label/errors div when present

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to autocomplete/1"
```

---

## Chunk 4: Remaining Components + Docs

### Task 9: Add FormField support to `radio_group/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 1176)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing tests**

```elixir
describe "radio_group with FormField" do
  test "extracts name and value from field" do
    form = Phoenix.Component.to_form(%{"plan" => "pro"}, as: :account)

    html =
      render_component(&Forms.radio_group/1, %{
        field: form[:plan],
        option: [
          %{value: "free", label: "Free", inner_block: fn -> "" end},
          %{value: "pro", label: "Pro", inner_block: fn -> "" end}
        ]
      })

    inputs = TestHelpers.find_all(html, "input[type='radio']")
    assert length(inputs) == 2
  end

  test "renders fieldset with legend for label" do
    form = Phoenix.Component.to_form(%{"plan" => "free"}, as: :account)

    html =
      render_component(&Forms.radio_group/1, %{
        field: form[:plan],
        label: "Choose a plan",
        option: [
          %{value: "free", label: "Free", inner_block: fn -> "" end}
        ]
      })

    assert html =~ "<fieldset"
    assert html =~ "<legend"
    assert html =~ "Choose a plan"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `radio_group/1`**

- Add `id`, `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- For label: wrap in `<fieldset>` with `<legend>` (not `<.label for=...>`)
- Render `<.field_error>` for errors

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to radio_group/1"
```

### Task 10: Add FormField support to `slider/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 1223)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing test**

```elixir
describe "slider with FormField" do
  test "extracts name and value from field" do
    form = Phoenix.Component.to_form(%{"volume" => "75"}, as: :settings)

    html =
      render_component(&Forms.slider/1, %{
        id: "volume",
        field: form[:volume]
      })

    assert TestHelpers.attr(html, "[data-slot='slider']", "name") == "settings[volume]"
  end
end
```

Note: slider uses `data-slot="slider"` on the `<input type="range">` element.

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `slider/1`**

Add `field`, `label`, `errors` (default `nil`) attrs. Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`. Wrap with label/errors div when present.

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to slider/1"
```

### Task 11: Add FormField support to `number_field/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 417-500)
- Modify: `test/cinder_ui/components/forms_test.exs`

- [ ] **Step 1: Write failing test**

```elixir
describe "number_field with FormField" do
  test "extracts id, name, value from field" do
    form = Phoenix.Component.to_form(%{"quantity" => "5"}, as: :order)

    html =
      render_component(&Forms.number_field/1, %{
        field: form[:quantity]
      })

    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "name") == "order[quantity]"
    assert TestHelpers.attr(html, "[data-slot='number-field-input']", "value") == "5"
  end

  test "renders label and errors" do
    form = Phoenix.Component.to_form(%{"qty" => ""}, as: :order)

    html =
      render_component(&Forms.number_field/1, %{
        field: form[:qty],
        label: "Quantity",
        errors: ["must be positive"]
      })

    assert TestHelpers.text(html, "[data-slot='label']") == "Quantity"
    assert TestHelpers.text(html, "[data-slot='field-error']") == "must be positive"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `number_field/1`**

- Change `id` from `required: true` to `default: nil` (generate unique default if nil, needed for JS onclick targets)
- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- Wrap with label/errors div when present

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to number_field/1"
```

### Task 12: Add FormField support to `input_otp/1`

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex` (around line 1445)
- Modify: `test/cinder_ui/components/forms_test.exs`

OTP is structurally different: it renders N individual `<input>` cells, each sharing the same `name` attr. The `field.value` is a single string (e.g., `"1234"`) that must be split into individual characters for the `values` list.

- [ ] **Step 1: Write failing test**

```elixir
describe "input_otp with FormField" do
  test "extracts name from field and splits value into cells" do
    form = Phoenix.Component.to_form(%{"code" => "1234"}, as: :verify)

    html =
      render_component(&Forms.input_otp/1, %{
        field: form[:code],
        length: 4
      })

    inputs = TestHelpers.find_all(html, "[data-input-otp-input]")
    assert length(inputs) == 4
    # First cell should have value "1"
    assert inputs |> List.first() |> Floki.attribute("value") |> List.first() == "1"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

- [ ] **Step 3: Update `input_otp/1`**

- Add `field`, `label`, `errors` (default `nil`) attrs
- Call `unwrap_field()` then `assign_new(:errors, fn -> [] end)`
- After unwrapping, if `value` is a string, split into `values` list: `assign_new(:values, fn -> String.graphemes(assigns.value || "") end)`
- `name` from field needs `[]` suffix for array submission: when field provides name, append `[]` (e.g., `"verify[code][]"`)
- Wrap with label/errors div when present

- [ ] **Step 4: Run tests to verify they pass**

- [ ] **Step 5: Commit**

```
git add lib/cinder_ui/components/forms.ex test/cinder_ui/components/forms_test.exs
git commit -m "feat(forms): add FormField support to input_otp/1"
```

### Task 13: Update doc blocks for all components

**Files:**
- Modify: `lib/cinder_ui/components/forms.ex`

- [ ] **Step 1: Update each component's `doc()` block**

For each of the 11 components, update the `doc()` call to add FormField examples after the existing raw-mode examples. Add these sections to each:

**For `input/1`** (adapt pattern for all components):
````
### With FormField

```heex title="FormField input"
<.input field={@form[:email]} />
```

### With label

```heex title="Labeled input"
<.input field={@form[:email]} label="Email address" />
```

### With explicit errors

```heex title="Custom errors"
<.input field={@form[:email]} label="Email" errors={["must contain @"]} />
```

### Inside field composition

```heex title="Composed field"
<.field>
  <:label><.label for={@form[:email].id}>Email</.label></:label>
  <.input field={@form[:email]} />
  <:description>We'll never share your email.</:description>
</.field>
```
````

Key per-component variations:
- **`checkbox/1`** and **`switch/1`**: show `inner_block` vs `label` attr, note inline label behaviour
- **`native_select/1`**: show both `options` attr and `:option` slots with `field`
- **`radio_group/1`**: show `<fieldset>/<legend>` label rendering
- **`select/1`** and **`autocomplete/1`**: show slot-based options with `field`
- **`input_otp/1`**: show how string value gets split into cells

- [ ] **Step 2: Compile to verify no doc errors**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix compile`

- [ ] **Step 3: Commit**

```
git add lib/cinder_ui/components/forms.ex
git commit -m "docs(forms): add FormField usage examples to all form component docs"
```

### Task 14: Run full test suite

- [ ] **Step 1: Run all tests**

Run: `cd /Users/levi/src/levibuzolic/cinder_ui && mix test`
Expected: All pass

- [ ] **Step 2: Fix any failures**

- [ ] **Step 3: Final commit if any fixes were needed**

```
git add -A
git commit -m "fix(forms): address test failures from FormField integration"
```
