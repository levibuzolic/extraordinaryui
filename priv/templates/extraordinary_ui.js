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

export const ExtraordinaryUIHooks = {
  EuiDialog,
  EuiDrawer,
  EuiPopover,
  EuiDropdownMenu,
  EuiCombobox,
  EuiCarousel,
}
