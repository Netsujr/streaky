import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["progressRing"]
  static values = {
    duration: { type: Number, default: 500 },
    cancelDelay: { type: Number, default: 50 }
  }

  connect() {
    this.setupProgressRing()
  }

  setupProgressRing() {
    if (this.hasProgressRingTarget) {
      const ring = this.progressRingTarget
      const size = 60
      const strokeWidth = 3
      const radius = (size - strokeWidth) / 2
      const circumference = radius * 2 * Math.PI

      ring.innerHTML = `
        <svg class="absolute inset-0 w-full h-full transform -rotate-90" viewBox="0 0 ${size} ${size}">
          <circle
            cx="${size / 2}"
            cy="${size / 2}"
            r="${radius}"
            fill="none"
            stroke="rgba(99, 102, 241, 0.3)"
            stroke-width="${strokeWidth}"
          />
          <circle
            cx="${size / 2}"
            cy="${size / 2}"
            r="${radius}"
            fill="none"
            stroke="rgba(99, 102, 241, 1)"
            stroke-width="${strokeWidth}"
            stroke-dasharray="${circumference}"
            stroke-dashoffset="${circumference}"
            class="transition-all duration-${this.durationValue} ease-out"
            data-progress-circle
          />
        </svg>
      `
      this.progressCircle = ring.querySelector('[data-progress-circle]')
      this.circumference = circumference
    }
  }

  start(event) {
    event.preventDefault()
    this.startTime = Date.now()
    this.timeout = setTimeout(() => {
      this.confirm()
    }, this.durationValue)

    if (this.hasProgressRingTarget) {
      this.animateProgress()
    }

    this.endHandler = (e) => this.cancel(e)
    this.element.addEventListener("mouseup", this.endHandler)
    this.element.addEventListener("mouseleave", this.endHandler)
    this.element.addEventListener("touchend", this.endHandler)
    this.element.addEventListener("touchcancel", this.endHandler)
  }

  cancel(event) {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }

    if (this.hasProgressRingTarget && this.progressCircle) {
      this.progressCircle.style.transition = `stroke-dashoffset ${this.cancelDelayValue}ms ease-out`
      this.progressCircle.style.strokeDashoffset = this.circumference
    }

    if (this.endHandler) {
      this.element.removeEventListener("mouseup", this.endHandler)
      this.element.removeEventListener("mouseleave", this.endHandler)
      this.element.removeEventListener("touchend", this.endHandler)
      this.element.removeEventListener("touchcancel", this.endHandler)
      this.endHandler = null
    }
  }

  confirm() {
    this.cancel()
    this.element.closest("form").requestSubmit()
  }

  animateProgress() {
    if (!this.progressCircle) return

    const startTime = Date.now()
    const duration = this.durationValue

    const animate = () => {
      const elapsed = Date.now() - startTime
      const progress = Math.min(elapsed / duration, 1)
      const offset = this.circumference - (progress * this.circumference)

      this.progressCircle.style.strokeDashoffset = offset

      if (progress < 1 && this.timeout) {
        requestAnimationFrame(animate)
      }
    }

    requestAnimationFrame(animate)
  }

  disconnect() {
    this.cancel()
  }
};
