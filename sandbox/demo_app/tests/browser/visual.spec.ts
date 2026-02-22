import { expect, test } from "@playwright/test"

test.describe("visual regression", () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("eui:theme:mode", "light")
      localStorage.setItem("eui:theme:color", "neutral")
      localStorage.setItem("eui:theme:radius", "nova")
    })

    await page.setViewportSize({ width: 1600, height: 1200 })
    await page.goto("/components")

    // Normalize typography/motion to improve screenshot consistency across runs.
    await page.addStyleTag({
      content: `
        *, *::before, *::after {
          animation: none !important;
          transition: none !important;
          caret-color: transparent !important;
        }

        body, button, input, select, textarea {
          font-family: Arial, Helvetica, sans-serif !important;
        }

        code, pre {
          font-family: "Courier New", monospace !important;
        }

        [data-component-card] [data-testid^="preview-"] {
          height: 220px !important;
          overflow: hidden !important;
        }
      `,
    })
  })

  test("captures each component card", async ({ page }) => {
    const cards = page.locator("[data-component-card]")
    const total = await cards.count()

    expect(total).toBeGreaterThan(0)

    for (let index = 0; index < total; index += 1) {
      const card = cards.nth(index)
      const id = await card.getAttribute("id")
      const snapshotName = `cards/${id ?? `card-${index}`}.png`
      const preview = card.locator("[data-testid^='preview-']")

      await preview.scrollIntoViewIfNeeded()
      await expect(preview).toBeVisible()
      await expect(preview).toHaveScreenshot(snapshotName)
    }
  })
})
