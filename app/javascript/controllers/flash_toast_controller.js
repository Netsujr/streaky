import { Controller } from "@hotwired/stimulus"

// closes flash toasts on button click and auto-dismisses after 2.5s; works with Turbo Stream updates
export default class extends Controller {
  static values = { dismissMs: { type: Number, default: 2500 } }

  connect() {
    this.flashEl = document.getElementById("flash")
    if (!this.flashEl) return

    this.boundClose = this.closeToast.bind(this)
    this.flashEl.addEventListener("click", this.boundClose)

    this.observer = new MutationObserver(() => this.setupToasts())
    this.observer.observe(this.flashEl, { childList: true, subtree: true })

    this.setupToasts()
  }

  disconnect() {
    if (this.flashEl) {
      this.flashEl.removeEventListener("click", this.boundClose)
      this.observer?.disconnect()
    }
  }

  closeToast(event) {
    const btn = event.target.closest(".flash-toast-close")
    if (!btn) return
    const toast = btn.closest(".flash-toast")
    if (toast) toast.remove()
  }

  setupToasts() {
    if (!this.flashEl) return
    this.flashEl.querySelectorAll(".flash-toast:not([data-flash-setup])").forEach((toast) => {
      toast.setAttribute("data-flash-setup", "true")
      setTimeout(() => toast.remove(), this.dismissMsValue)
    })
  }
}
