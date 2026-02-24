import { expect, test } from "@playwright/test"

const hasClass = async (locator: { evaluate: any }, className: string) =>
  locator.evaluate((el: Element, cls: string) => el.classList.contains(cls), className)

test.describe("interactive previews", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/docs/index.html")
  })

  test("dialog opens and closes", async ({ page }) => {
    const root = page.locator("[data-slot='dialog']").first()
    const content = root.locator("[data-dialog-content]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await root.locator("[data-dialog-trigger]").click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await root.locator("[data-dialog-close]").evaluate((el: HTMLElement) => el.click())
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("drawer opens and closes via overlay", async ({ page }) => {
    const root = page.locator("[data-slot='drawer']").first()
    const content = root.locator("[data-drawer-content]")
    const overlay = root.locator("[data-drawer-overlay]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await root.locator("[data-drawer-trigger]").click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await overlay.evaluate((el: HTMLElement) => el.click())
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("popover and dropdown toggle", async ({ page }) => {
    const popover = page.locator("[data-slot='popover']").first()
    const popoverContent = popover.locator("[data-popover-content]")

    await popover.scrollIntoViewIfNeeded()
    expect(await hasClass(popoverContent, "hidden")).toBe(true)
    await popover.locator("[data-popover-trigger]").click()
    expect(await hasClass(popoverContent, "hidden")).toBe(false)

    const dropdown = page.locator("[data-slot='dropdown-menu']").first()
    const dropdownContent = dropdown.locator("[data-dropdown-content]")

    await dropdown.scrollIntoViewIfNeeded()
    expect(await hasClass(dropdownContent, "hidden")).toBe(true)
    await dropdown.locator("[data-dropdown-trigger]").click()
    expect(await hasClass(dropdownContent, "hidden")).toBe(false)
  })

  test("combobox filters and selects", async ({ page }) => {
    const combo = page.locator("[data-slot='combobox']").first()
    const input = combo.locator("[data-combobox-input]")
    const content = combo.locator("[data-combobox-content]")

    await combo.scrollIntoViewIfNeeded()
    await input.click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await input.fill("Fr")
    const itemStates = await combo
      .locator("[data-slot='combobox-item']")
      .evaluateAll((els) =>
        els.map((el) => ({
          text: (el.textContent || "").trim(),
          hidden: el.classList.contains("hidden"),
        })),
      )

    const free = itemStates.find((item) => item.text === "Free")
    const pro = itemStates.find((item) => item.text === "Pro")

    expect(free?.hidden).toBe(false)
    expect(pro?.hidden).toBe(true)

    await combo.locator("[data-slot='combobox-item'][data-value='Free']").click()
    await expect(input).toHaveValue("Free")
  })

  test("carousel controls render", async ({ page }) => {
    const carousels = page.locator("[data-slot='carousel']")
    const count = await carousels.count()
    expect(count).toBeGreaterThan(0)

    const first = carousels.first()
    await expect(first.locator("[data-carousel-track]")).toHaveCount(1)
    await expect(first.locator("[data-carousel-prev]")).toHaveCount(1)
    await expect(first.locator("[data-carousel-next]")).toHaveCount(1)
  })

  test("resizable structure renders", async ({ page }) => {
    const resizable = page.locator("[data-slot='resizable']").first()

    if ((await resizable.count()) === 0) {
      test.skip()
      return
    }

    const panels = resizable.locator(":scope > [data-slot='resizable-panel']")
    const handle = resizable.locator(":scope > [data-slot='resizable-handle']")

    if ((await panels.count()) < 2) {
      test.skip()
      return
    }

    await resizable.scrollIntoViewIfNeeded()
    await expect(panels).toHaveCount(2)
    await expect(handle).toHaveCount(1)
  })

  test("theme controls apply mode, color, and radius", async ({ page }) => {
    await page.locator("[data-theme-mode='dark']").first().click()
    await expect(page.locator("html")).toHaveClass(/dark/)

    await page.locator("#theme-color").selectOption("slate")
    const primary = await page.locator("html").evaluate((el) => getComputedStyle(el).getPropertyValue("--primary").trim())
    expect(primary).toBe("oklch(0.929 0.013 255.508)")

    await page.locator("#theme-radius").selectOption("vega")
    const radius = await page.locator("html").evaluate((el) => getComputedStyle(el).getPropertyValue("--radius").trim())
    expect(radius).toBe("1rem")
  })

  test("command palette opens from sidebar trigger", async ({ page }) => {
    await page.goto("/docs")

    const trigger = page.locator("[data-open-command-palette]").first()
    const shell = page.locator(".docs-k")
    const input = page.locator(".docs-k-input")
    const listItems = page.locator(".docs-k-item")

    await trigger.scrollIntoViewIfNeeded()
    await expect(trigger).toBeVisible()

    await trigger.click()

    await expect(shell).toBeVisible()
    await expect(shell).not.toHaveClass(/hidden/)
    await expect(trigger).toHaveAttribute("aria-expanded", "true")
    await expect(input).toBeFocused()
    await expect(listItems.first()).toBeVisible()

    await page.keyboard.press("Escape")
    await expect(shell).toHaveClass(/hidden/)
    await expect(trigger).toHaveAttribute("aria-expanded", "false")
  })
})
