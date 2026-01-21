import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="confirmation-modal"
export default class extends Controller {
  static targets = ["title", "message"]
  static values = {
    confirmUrl: String,
    confirmMethod: String
  }

  connect() {
    // Hide modal on ESC key
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)

    // Hide modal when clicking outside
    this.boundHandleBackdrop = this.handleBackdrop.bind(this)
    this.element.addEventListener("click", this.boundHandleBackdrop)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
    this.element.removeEventListener("click", this.boundHandleBackdrop)
  }

  show(event) {
    // Prevent default link/button behavior
    event.preventDefault()
    event.stopPropagation()

    // Get data from the triggering element
    const trigger = event.currentTarget
    this.lastTrigger = trigger // Store for focus return

    // Rails converts data-url to dataset.url, data-confirm-title to dataset.confirmTitle, etc.
    const title = trigger.dataset.confirmTitle || trigger.getAttribute("data-confirm-title") || "Confirm Action"
    const message = trigger.dataset.confirmMessage || trigger.getAttribute("data-confirm-message") || "Are you sure you want to proceed?"
    const url = trigger.dataset.url || trigger.getAttribute("data-url") || trigger.href || this.confirmUrlValue
    const method = trigger.dataset.method || trigger.getAttribute("data-method") || trigger.dataset.turboMethod || trigger.getAttribute("data-turbo-method") || this.confirmMethodValue || "get"

    // Debug logging
    console.log("Modal show triggered:", { title, message, url, method })
    console.log("Trigger element dataset:", trigger.dataset)
    console.log("Trigger href:", trigger.href)
    console.log("All data attributes:", Array.from(trigger.attributes).filter(attr => attr.name.startsWith("data-")))

    // Validate URL
    if (!url || url === "#" || url === window.location.href + "#") {
      console.error("Invalid URL:", url)
      alert("Error: Could not determine action URL. Please refresh the page and try again.")
      return
    }

    // Find the modal element (it has id="confirmation-modal" and data-controller="confirmation-modal")
    const modalElement = document.getElementById("confirmation-modal")
    if (!modalElement) {
      console.error("Modal element not found in DOM")
      alert("Error: Confirmation modal not found. Please refresh the page.")
      return
    }

    // Store the action data on the modal element itself so any controller instance can access it
    // Use setAttribute to ensure it's stored correctly
    modalElement.setAttribute("data-confirm-url", url)
    modalElement.setAttribute("data-confirm-method", method)
    console.log("Stored action data on modal:", { url, method })
    console.log("Modal dataset after storage:", modalElement.dataset)

    // Update modal content - need to find targets within the modal element
    const titleTarget = modalElement.querySelector('[data-confirmation-modal-target="title"]')
    const messageTarget = modalElement.querySelector('[data-confirmation-modal-target="message"]')

    if (titleTarget) {
      titleTarget.textContent = title
    }
    if (messageTarget) {
      messageTarget.textContent = message
    }

    // Show modal
    console.log("Modal element before show:", modalElement)
    console.log("Modal has 'hidden' class:", modalElement.classList.contains("hidden"))
    modalElement.classList.remove("hidden")
    console.log("Modal has 'hidden' class after remove:", modalElement.classList.contains("hidden"))
    console.log("Modal computed display:", window.getComputedStyle(modalElement).display)
    document.body.style.overflow = "hidden" // Prevent background scrolling

    // Focus the confirm button for accessibility
    setTimeout(() => {
      const confirmButton = modalElement.querySelector('button[data-action*="confirm"]')
      if (confirmButton) {
        confirmButton.focus()
      } else {
        console.error("Confirm button not found in modal")
      }
    }, 100)
  }

  hide() {
    const modalElement = document.getElementById("confirmation-modal")
    if (modalElement) {
      modalElement.classList.add("hidden")
    }
    document.body.style.overflow = "" // Restore scrolling

    // Return focus to the trigger element
    if (this.lastTrigger) {
      setTimeout(() => {
        this.lastTrigger.focus()
        this.lastTrigger = null
      }, 100)
    }
  }

  confirm() {
    // Get the action data from the modal element (stored by the show method)
    const modalElement = document.getElementById("confirmation-modal")
    if (!modalElement) {
      console.error("Modal element not found")
      this.hide()
      return
    }

    console.log("Modal element dataset:", modalElement.dataset)
    console.log("Modal element attributes:", Array.from(modalElement.attributes).filter(attr => attr.name.startsWith("data-confirm")))

    const url = modalElement.dataset.confirmUrl || modalElement.getAttribute("data-confirm-url")
    const method = modalElement.dataset.confirmMethod || modalElement.getAttribute("data-confirm-method") || "get"

    console.log("Retrieved from modal:", { url, method })

    if (!url) {
      console.error("No confirm action stored on modal element")
      console.error("Modal dataset:", modalElement.dataset)
      console.error("Modal getAttribute data-confirm-url:", modalElement.getAttribute("data-confirm-url"))
      this.hide()
      return
    }

    console.log("Confirming action:", { url, method })

    // Validate URL again
    if (!url || url === "#" || url === window.location.href + "#") {
      console.error("Invalid URL in confirm:", url)
      alert("Error: Invalid action URL. Please refresh the page and try again.")
      this.hide()
      return
    }

    // Hide modal first
    this.hide()

    // Create a form for submission
    const form = document.createElement("form")
    form.method = "post"
    form.action = url
    form.style.display = "none"
    // Explicitly disable Turbo to ensure full page submission
    form.setAttribute("data-turbo", "false")

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) {
      console.error("CSRF token not found")
      alert("Error: CSRF token not found. Please refresh the page and try again.")
      return
    }

    // Add CSRF token
    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // Add method override for PATCH/DELETE
    const methodValue = method ? method.toLowerCase() : "get"
    console.log("Method value:", methodValue)
    if (methodValue !== "get" && methodValue !== "post") {
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = methodValue
      form.appendChild(methodInput)
      console.log("Added method override:", methodValue)
    }

    // Append to body
    document.body.appendChild(form)

    // Log form details before submission
    console.log("Submitting form:", {
      action: form.action,
      method: form.method,
      hasMethodOverride: form.querySelector('input[name="_method"]') !== null,
      methodOverrideValue: form.querySelector('input[name="_method"]')?.value
    })

    // Submit the form - this will cause a full page reload with the redirect
    form.submit()
  }

  submitFormFallback(url, method) {
    // Fallback: create and submit a regular form
    const form = document.createElement("form")
    form.method = "post"
    form.action = url
    form.style.display = "none"

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }

    const methodValue = method ? method.toLowerCase() : "get"
    if (methodValue !== "get" && methodValue !== "post") {
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = methodValue
      form.appendChild(methodInput)
    }

    document.body.appendChild(form)
    form.submit()
  }

  cancel() {
    this.hide()
  }

  handleEscape(event) {
    const modalElement = document.getElementById("confirmation-modal")
    if (event.key === "Escape" && modalElement && !modalElement.classList.contains("hidden")) {
      this.hide()
    }
  }

  handleBackdrop(event) {
    // If clicking directly on the backdrop (not the modal content), close it
    const modalElement = document.getElementById("confirmation-modal")
    if (modalElement && event.target === modalElement) {
      this.hide()
    }
  }
}
