import fs from "node:fs"
import path from "node:path"

const repoRoot = process.cwd()
const resultsDir = path.resolve(repoRoot, process.env.PLAYWRIGHT_RESULTS_DIR || "demo/test-results")
const summaryPath = process.env.GITHUB_STEP_SUMMARY
const artifactUrl = process.env.PLAYWRIGHT_ARTIFACT_URL || ""
const maxInlineImages = Number.parseInt(process.env.PLAYWRIGHT_VRT_MAX_INLINE || "6", 10)

function walk(dir) {
  const entries = []

  for (const dirent of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, dirent.name)

    if (dirent.isDirectory()) {
      entries.push(...walk(fullPath))
      continue
    }

    entries.push(fullPath)
  }

  return entries
}

function escWorkflowCommand(message) {
  return message.replaceAll("%", "%25").replaceAll("\r", "%0D").replaceAll("\n", "%0A")
}

function toRepoRel(filePath) {
  return path.relative(repoRoot, filePath).split(path.sep).join("/")
}

function inlineImage(filePath) {
  try {
    const bytes = fs.readFileSync(filePath)
    return `data:image/png;base64,${bytes.toString("base64")}`
  } catch {
    return ""
  }
}

function main() {
  if (!fs.existsSync(resultsDir)) {
    console.log(`No Playwright results directory found at ${resultsDir}`)
    return
  }

  const files = walk(resultsDir)
  const actuals = files.filter((file) => file.endsWith("-actual.png"))
  const failures = actuals
    .map((actual) => {
      const prefix = actual.slice(0, -"-actual.png".length)
      const expected = `${prefix}-expected.png`
      const diff = `${prefix}-diff.png`

      if (!fs.existsSync(expected) || !fs.existsSync(diff)) return null

      return {
        name: path.basename(prefix),
        actual,
        expected,
        diff,
      }
    })
    .filter(Boolean)

  if (failures.length === 0) {
    console.log("No failed Playwright screenshot comparisons found.")
    return
  }

  for (const failure of failures) {
    const msg =
      `${failure.name} screenshot mismatch. ` +
      `expected=${toRepoRel(failure.expected)} actual=${toRepoRel(failure.actual)} diff=${toRepoRel(failure.diff)}`
    console.log(`::error file=demo/tests/browser/visual.spec.ts,line=1,title=Playwright VRT mismatch::${escWorkflowCommand(msg)}`)
  }

  const lines = []
  lines.push("## Playwright Visual Regression Failures")
  lines.push("")
  lines.push(`Found **${failures.length}** failed screenshot comparison(s).`)
  if (artifactUrl) {
    lines.push("")
    lines.push(`Artifacts: [playwright-artifacts](${artifactUrl})`)
  }
  lines.push("")
  lines.push("| Snapshot | Diff Preview | Expected | Actual | Diff |")
  lines.push("| --- | --- | --- | --- | --- |")

  failures.forEach((failure, index) => {
    const expectedRel = toRepoRel(failure.expected)
    const actualRel = toRepoRel(failure.actual)
    const diffRel = toRepoRel(failure.diff)
    const preview =
      index < maxInlineImages
        ? `<img src="${inlineImage(failure.diff)}" alt="${failure.name} diff" width="280" />`
        : "_preview omitted_"

    lines.push(
      `| \`${failure.name}\` | ${preview} | \`${expectedRel}\` | \`${actualRel}\` | \`${diffRel}\` |`
    )
  })

  const content = `${lines.join("\n")}\n`
  if (summaryPath) {
    fs.appendFileSync(summaryPath, content)
  } else {
    process.stdout.write(content)
  }
}

main()
