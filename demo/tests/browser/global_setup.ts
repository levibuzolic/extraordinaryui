import { execFileSync } from "node:child_process"
import path from "node:path"
import type { FullConfig } from "@playwright/test"

export default function globalSetup(config: FullConfig) {
  const demoRoot = config.configFile ? path.dirname(config.configFile) : process.cwd()

  execFileSync("mix", ["assets.build"], {
    cwd: demoRoot,
    stdio: "inherit",
  })
}
