import { Controller } from "@hotwired/stimulus"

// Modal for habit check-in calendar. Close on backdrop click or close button; ignore clicks inside panel.
export default class extends Controller {
  static targets = ["frame", "panel"]

  connect() {
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  close(event) {
    if (event) {
      const isBackdrop = event.target === this.element
      const isCloseControl = event.target.closest("[data-action*='habit-calendar#close']")
      if (!isBackdrop && !isCloseControl) return
    }
    this.element.classList.add("hidden")
    document.body.style.overflow = ""
    if (this.hasFrameTarget) {
      this.frameTarget.removeAttribute("src")
    }
  }

  ignore(event) {
    event.stopPropagation()
  }

  handleEscape(event) {
    if (event.key === "Escape" && !this.element.classList.contains("hidden")) {
      this.close()
    }
  }
}
