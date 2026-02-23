const toggleVisibility = (el, visible) => {
  if (!el) return
  if (visible) {
    el.classList.remove("hidden")
    el.dataset.state = "open"
  } else {
    el.classList.add("hidden")
    el.dataset.state = "closed"
  }
}

const clickClosest = (target, selector) => target && target.closest(selector)
const clamp = (value, min, max) => Math.min(Math.max(value, min), max)

const parsePercentage = (value, fallback) => {
  if (value === null || value === undefined || value === "") return fallback
  const parsed = Number.parseFloat(value)
  return Number.isFinite(parsed) ? parsed : fallback
}

const normalizePercentages = (values) => {
  if (!values.length) return values
  const total = values.reduce((sum, value) => sum + value, 0)
  if (total <= 0) return values.map(() => 100 / values.length)
  return values.map((value) => (value / total) * 100)
}

const EuiDialog = {
  mounted() {
    this.sync(this.el.dataset.state === "open")

    this.handleEvent = (event) => {
      if (clickClosest(event.target, "[data-dialog-trigger]")) this.sync(true)
      if (clickClosest(event.target, "[data-dialog-close]") || clickClosest(event.target, "[data-dialog-overlay]")) this.sync(false)
    }

    this.el.addEventListener("click", this.handleEvent)
  },

  updated() {
    this.sync(this.el.dataset.state === "open")
  },

  sync(open) {
    this.el.dataset.state = open ? "open" : "closed"
    toggleVisibility(this.el.querySelector("[data-dialog-overlay]"), open)
    toggleVisibility(this.el.querySelector("[data-dialog-content]"), open)
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleEvent)
  },
}

const EuiDrawer = {
  mounted() {
    this.sync(this.el.dataset.state === "open")

    this.handleEvent = (event) => {
      if (clickClosest(event.target, "[data-drawer-trigger]")) this.sync(true)
      if (clickClosest(event.target, "[data-drawer-overlay]")) this.sync(false)
    }

    this.el.addEventListener("click", this.handleEvent)
  },

  updated() {
    this.sync(this.el.dataset.state === "open")
  },

  sync(open) {
    this.el.dataset.state = open ? "open" : "closed"
    toggleVisibility(this.el.querySelector("[data-drawer-overlay]"), open)
    toggleVisibility(this.el.querySelector("[data-drawer-content]"), open)
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleEvent)
  },
}

const EuiPopover = {
  mounted() {
    this.open = false
    this.trigger = this.el.querySelector("[data-popover-trigger]")
    this.content = this.el.querySelector("[data-popover-content]")

    this.toggle = () => {
      this.open = !this.open
      toggleVisibility(this.content, this.open)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        this.open = false
        toggleVisibility(this.content, false)
      }
    }

    this.trigger && this.trigger.addEventListener("click", this.toggle)
    document.addEventListener("click", this.onDocumentClick)
  },

  destroyed() {
    this.trigger && this.trigger.removeEventListener("click", this.toggle)
    document.removeEventListener("click", this.onDocumentClick)
  },
}

const EuiDropdownMenu = {
  mounted() {
    this.open = false
    this.trigger = this.el.querySelector("[data-dropdown-trigger]")
    this.content = this.el.querySelector("[data-dropdown-content]")

    this.toggle = () => {
      this.open = !this.open
      toggleVisibility(this.content, this.open)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        this.open = false
        toggleVisibility(this.content, false)
      }
    }

    this.trigger && this.trigger.addEventListener("click", this.toggle)
    document.addEventListener("click", this.onDocumentClick)
  },

  destroyed() {
    this.trigger && this.trigger.removeEventListener("click", this.toggle)
    document.removeEventListener("click", this.onDocumentClick)
  },
}

const EuiCombobox = {
  mounted() {
    this.input = this.el.querySelector("[data-combobox-input]")
    this.content = this.el.querySelector("[data-combobox-content]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='combobox-item']"))

    this.onInput = () => {
      const value = (this.input.value || "").toLowerCase()
      this.items.forEach((item) => {
        const text = item.textContent.toLowerCase()
        const visible = text.includes(value)
        item.classList.toggle("hidden", !visible)
      })
      toggleVisibility(this.content, true)
    }

    this.onItemClick = (event) => {
      const item = event.currentTarget
      this.input.value = item.dataset.value || item.textContent.trim()
      toggleVisibility(this.content, false)
    }

    this.onDocumentClick = (event) => {
      if (!this.el.contains(event.target)) {
        toggleVisibility(this.content, false)
      }
    }

    this.input && this.input.addEventListener("focus", () => toggleVisibility(this.content, true))
    this.input && this.input.addEventListener("input", this.onInput)
    this.items.forEach((item) => item.addEventListener("click", this.onItemClick))
    document.addEventListener("click", this.onDocumentClick)
  },

  destroyed() {
    this.input && this.input.removeEventListener("input", this.onInput)
    this.items.forEach((item) => item.removeEventListener("click", this.onItemClick))
    document.removeEventListener("click", this.onDocumentClick)
  },
}

const EuiCarousel = {
  mounted() {
    this.index = 0
    this.track = this.el.querySelector("[data-carousel-track]")
    this.items = Array.from(this.el.querySelectorAll("[data-slot='carousel-item']"))
    this.prev = this.el.querySelector("[data-carousel-prev]")
    this.next = this.el.querySelector("[data-carousel-next]")

    this.sync = () => {
      if (!this.track || this.items.length === 0) return
      const percentage = this.index * 100
      this.track.style.transform = `translateX(-${percentage}%)`
      this.track.style.transition = "transform 240ms ease"
    }

    this.onPrev = () => {
      this.index = this.index === 0 ? this.items.length - 1 : this.index - 1
      this.sync()
    }

    this.onNext = () => {
      this.index = this.index === this.items.length - 1 ? 0 : this.index + 1
      this.sync()
    }

    this.prev && this.prev.addEventListener("click", this.onPrev)
    this.next && this.next.addEventListener("click", this.onNext)
    this.sync()
  },

  destroyed() {
    this.prev && this.prev.removeEventListener("click", this.onPrev)
    this.next && this.next.removeEventListener("click", this.onNext)
  },
}

const EuiResizable = {
  mounted() {
    this.setup()
  },

  updated() {
    this.setup()
  },

  setup() {
    this.teardown()

    this.direction = this.el.dataset.direction === "vertical" ? "vertical" : "horizontal"
    this.storageKey = this.el.dataset.storageKey || null
    this.panels = Array.from(this.el.querySelectorAll(":scope > [data-slot='resizable-panel']"))
    this.handles = Array.from(this.el.querySelectorAll(":scope > [data-slot='resizable-handle']"))

    if (this.panels.length < 2) return

    this.sizes = this.loadSizes()
    this.applySizes(this.sizes)
    this.bindHandles()
  },

  loadSizes() {
    const fromStorage = this.loadSizesFromStorage()
    if (fromStorage) return fromStorage

    const configured = this.panels.map((panel) => {
      const fromData = parsePercentage(panel.dataset.size, NaN)
      if (Number.isFinite(fromData)) return fromData
      return parsePercentage(panel.style.flexBasis, NaN)
    })

    const fallback = configured.every((value) => Number.isFinite(value))
      ? configured
      : this.panels.map(() => 100 / this.panels.length)

    return normalizePercentages(fallback)
  },

  loadSizesFromStorage() {
    if (!this.storageKey || !window.localStorage) return null

    try {
      const raw = window.localStorage.getItem(this.storageKey)
      if (!raw) return null
      const parsed = JSON.parse(raw)
      if (!Array.isArray(parsed) || parsed.length !== this.panels.length) return null
      const values = parsed.map((value) => Number.parseFloat(value))
      if (values.some((value) => !Number.isFinite(value))) return null
      return normalizePercentages(values)
    } catch (_error) {
      return null
    }
  },

  saveSizes() {
    if (!this.storageKey || !window.localStorage) return
    try {
      const serialized = this.sizes.map((value) => Number(value.toFixed(4)))
      window.localStorage.setItem(this.storageKey, JSON.stringify(serialized))
    } catch (_error) {
      // Ignore localStorage errors.
    }
  },

  panelMinSize(index) {
    return parsePercentage(this.panels[index]?.dataset.minSize, 10)
  },

  axisCoordinate(event) {
    return this.direction === "horizontal" ? event.clientX : event.clientY
  },

  axisLength() {
    const rect = this.el.getBoundingClientRect()
    return this.direction === "horizontal" ? rect.width : rect.height
  },

  applySizes(nextSizes) {
    this.sizes = normalizePercentages(nextSizes)
    this.panels.forEach((panel, index) => {
      const size = this.sizes[index]
      panel.style.flex = `0 0 ${size}%`
      panel.dataset.size = String(Number(size.toFixed(4)))
    })
  },

  adjustPair(index, deltaPercent) {
    const leftIndex = index
    const rightIndex = index + 1
    const leftSize = this.sizes[leftIndex]
    const rightSize = this.sizes[rightIndex]
    const pairTotal = leftSize + rightSize
    const leftMin = this.panelMinSize(leftIndex)
    const rightMin = this.panelMinSize(rightIndex)

    const nextLeft = clamp(leftSize + deltaPercent, leftMin, pairTotal - rightMin)
    const nextRight = pairTotal - nextLeft
    const nextSizes = [...this.sizes]
    nextSizes[leftIndex] = nextLeft
    nextSizes[rightIndex] = nextRight
    this.applySizes(nextSizes)
    this.saveSizes()
  },

  bindHandles() {
    this.cleanups = []

    this.handles.forEach((handle, index) => {
      if (index >= this.panels.length - 1) return

      const onPointerDown = (event) => {
        event.preventDefault()

        const startCoord = this.axisCoordinate(event)
        const startSizes = [...this.sizes]
        const length = this.axisLength()
        if (!length || length <= 0) return

        const leftIndex = index
        const rightIndex = index + 1
        const pairTotal = startSizes[leftIndex] + startSizes[rightIndex]
        const leftMin = this.panelMinSize(leftIndex)
        const rightMin = this.panelMinSize(rightIndex)

        const onPointerMove = (moveEvent) => {
          const deltaPixels = this.axisCoordinate(moveEvent) - startCoord
          const deltaPercent = (deltaPixels / length) * 100
          const nextLeft = clamp(startSizes[leftIndex] + deltaPercent, leftMin, pairTotal - rightMin)
          const nextRight = pairTotal - nextLeft
          const nextSizes = [...this.sizes]
          nextSizes[leftIndex] = nextLeft
          nextSizes[rightIndex] = nextRight
          this.applySizes(nextSizes)
        }

        const onPointerUp = () => {
          window.removeEventListener("pointermove", onPointerMove)
          window.removeEventListener("pointerup", onPointerUp)
          window.removeEventListener("pointercancel", onPointerUp)
          this.saveSizes()
        }

        window.addEventListener("pointermove", onPointerMove)
        window.addEventListener("pointerup", onPointerUp)
        window.addEventListener("pointercancel", onPointerUp)
      }

      const onKeyDown = (event) => {
        const step = event.shiftKey ? 10 : 2

        if (this.direction === "horizontal" && event.key === "ArrowLeft") {
          event.preventDefault()
          this.adjustPair(index, -step)
        }

        if (this.direction === "horizontal" && event.key === "ArrowRight") {
          event.preventDefault()
          this.adjustPair(index, step)
        }

        if (this.direction === "vertical" && event.key === "ArrowUp") {
          event.preventDefault()
          this.adjustPair(index, -step)
        }

        if (this.direction === "vertical" && event.key === "ArrowDown") {
          event.preventDefault()
          this.adjustPair(index, step)
        }
      }

      handle.addEventListener("pointerdown", onPointerDown)
      handle.addEventListener("keydown", onKeyDown)

      this.cleanups.push(() => {
        handle.removeEventListener("pointerdown", onPointerDown)
        handle.removeEventListener("keydown", onKeyDown)
      })
    })
  },

  teardown() {
    if (this.cleanups) {
      this.cleanups.forEach((cleanup) => cleanup())
    }
    this.cleanups = []
  },

  destroyed() {
    this.teardown()
  },
}

export const CinderUIHooks = {
  EuiDialog,
  EuiDrawer,
  EuiPopover,
  EuiDropdownMenu,
  EuiCombobox,
  EuiCarousel,
  EuiResizable,
}
