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

  test("sidebar navigation renders section and component links", async ({ page }) => {
    const sidebar = page.locator("nav[aria-label='Component sections']")
    await expect(sidebar).toBeVisible()
    await expect(sidebar.getByRole("link", { name: "Actions" })).toBeVisible()
    await expect(sidebar.getByRole("link", { name: "button", exact: true })).toBeVisible()
    await expect(page.locator("#component-search")).toHaveCount(0)
  })

  test("cards expose HEEx snippets", async ({ page }) => {
    const firstCard = page.locator("[data-component-card]").first()
    await expect(firstCard.getByRole("button", { name: "Copy HEEx" })).toBeVisible()
    await firstCard.locator("summary", { hasText: "Phoenix template (HEEx)" }).click()

    const code = firstCard.locator("code[id^='code-']").first()
    await expect(code).toContainText("<.")
  })
})
