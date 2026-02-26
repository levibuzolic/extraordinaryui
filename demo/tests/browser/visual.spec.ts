import path from "node:path"
import { mkdir } from "node:fs/promises"
import { expect, test } from "@playwright/test"

test.describe("visual regression", () => {
  test.use({
    viewport: { width: 1600, height: 1200 },
    deviceScaleFactor: 2,
  })

  const screenshotOutputDir = path.resolve(__dirname, "../../../doc/screenshots")

  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem("cui:theme:mode", "light")
      localStorage.setItem("cui:theme:color", "neutral")
      localStorage.setItem("cui:theme:radius", "nova")
    })

    await page.goto("/docs/")

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

        [data-component-card] [data-preview-align] {
          height: 220px !important;
          overflow: hidden !important;
        }
      `,
    })
  })

  test("captures each component card", async ({ page }) => {
    await mkdir(screenshotOutputDir, { recursive: true })

    const cards = page.locator("[data-component-card]")
    const total = await cards.count()

    expect(total).toBeGreaterThan(0)

    for (let index = 0; index < total; index += 1) {
      const card = cards.nth(index)
      const id = await card.getAttribute("id")
      const componentId = id ?? `card-${index}`
      const snapshotName = `cards/${componentId}.png`
      const preview = card.locator("[data-preview-align]").first()

      await preview.scrollIntoViewIfNeeded()
      await expect(preview).toBeVisible()
      await expect(preview).toHaveScreenshot(snapshotName, { scale: "device" })
      await preview.screenshot({
        path: path.join(screenshotOutputDir, `${componentId}.png`),
        scale: "device",
      })
    }
  })
})
