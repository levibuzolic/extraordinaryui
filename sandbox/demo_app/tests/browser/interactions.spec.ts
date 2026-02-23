import { expect, test } from "@playwright/test"

const hasClass = async (locator: { evaluate: any }, className: string) =>
  locator.evaluate((el: Element, cls: string) => el.classList.contains(cls), className)

test.describe("interactive previews", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/components")
  })

  test("dialog opens and closes", async ({ page }) => {
    const root = page.locator("#overlay-dialog #docs-dialog")
    const content = root.locator("[data-dialog-content]")

    await root.scrollIntoViewIfNeeded()
    expect(await hasClass(content, "hidden")).toBe(true)

    await root.locator("[data-dialog-trigger]").click()
    expect(await hasClass(content, "hidden")).toBe(false)

    await root.locator("[data-dialog-close]").evaluate((el: HTMLElement) => el.click())
    expect(await hasClass(content, "hidden")).toBe(true)
  })

  test("drawer opens and closes via overlay", async ({ page }) => {
    const root = page.locator("#overlay-drawer #docs-drawer")
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
    const popover = page.locator("#overlay-popover #docs-popover")
    const popoverContent = popover.locator("[data-popover-content]")

    await popover.scrollIntoViewIfNeeded()
    expect(await hasClass(popoverContent, "hidden")).toBe(true)
    await popover.locator("[data-popover-trigger]").click()
    expect(await hasClass(popoverContent, "hidden")).toBe(false)

    const dropdown = page.locator("#overlay-dropdown_menu #docs-dropdown")
    const dropdownContent = dropdown.locator("[data-dropdown-content]")

    await dropdown.scrollIntoViewIfNeeded()
    expect(await hasClass(dropdownContent, "hidden")).toBe(true)
    await dropdown.locator("[data-dropdown-trigger]").click()
    expect(await hasClass(dropdownContent, "hidden")).toBe(false)
  })

  test("combobox filters and selects", async ({ page }) => {
    const combo = page.locator("#advanced-combobox #docs-combobox")
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

  test("carousel next/previous updates transform", async ({ page }) => {
    const carousel = page.locator("#advanced-carousel #docs-carousel")
    const track = carousel.locator("[data-carousel-track]")

    await carousel.scrollIntoViewIfNeeded()
    const before = await track.evaluate((el) => getComputedStyle(el).transform)

    await carousel.locator("[data-carousel-next]").click()
    await page.waitForTimeout(300)
    const afterNext = await track.evaluate((el) => getComputedStyle(el).transform)
    expect(afterNext).not.toBe(before)

    await carousel.locator("[data-carousel-prev]").evaluate((el: HTMLElement) => el.click())
    await page.waitForTimeout(300)
    const afterPrev = await track.evaluate((el) => getComputedStyle(el).transform)
    expect(afterPrev).not.toBe(afterNext)
  })

  test("theme controls apply mode, color, and radius", async ({ page }) => {
    await page.getByRole("button", { name: "Dark" }).click()
    await expect(page.locator("html")).toHaveClass(/dark/)

    await page.getByTestId("theme-color").selectOption("slate")
    const primary = await page.locator("html").evaluate((el) => getComputedStyle(el).getPropertyValue("--primary").trim())
    expect(primary).toBe("oklch(0.929 0.013 255.508)")

    await page.getByTestId("theme-radius").selectOption("vega")
    const radius = await page.locator("html").evaluate((el) => getComputedStyle(el).getPropertyValue("--radius").trim())
    expect(radius).toBe("1rem")
  })
})
