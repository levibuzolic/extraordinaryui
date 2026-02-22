import { expect, test } from "@playwright/test"

test.describe("component catalog", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/components")
  })

  test("renders every component card", async ({ page }) => {
    const countText = (await page.getByTestId("component-count").textContent()) ?? "0"
    const expectedCount = Number.parseInt(countText.trim(), 10)

    const cards = page.locator("[data-component-card]")
    await expect(cards).toHaveCount(expectedCount)

    for (let i = 0; i < expectedCount; i += 1) {
      const card = cards.nth(i)
      await expect(card).toBeVisible()
      await expect(card.locator("h3 code")).toBeVisible()
    }

    await expect(page.locator("text=Render error")).toHaveCount(0)
  })

  test("search filters component cards", async ({ page }) => {
    const cards = page.locator("[data-component-card]")
    const initialCount = await cards.count()

    await page.locator("#component-search").fill("dialog")

    const visibleCards = page.locator("[data-component-card]:visible")
    await expect(visibleCards).toHaveCount(2)
    await expect(visibleCards.first()).toContainText("alert_dialog")
    await expect(visibleCards.nth(1)).toContainText("dialog")

    await page.locator("#component-search").fill("")
    await expect(cards).toHaveCount(initialCount)
  })
})
