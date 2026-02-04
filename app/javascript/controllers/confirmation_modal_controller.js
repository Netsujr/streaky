import { Controller } from "@hotwired/stimulus"

// connects to data-controller="confirmation-modal" - handles archive/delete/restore confirmations (https://stimulus.hotwired.dev/reference/controllers)
export default class extends Controller {
  static targets = ["title", "message"]
  static values = {
    confirmUrl: String,
    confirmMethod: String
  }

  connect() {
    // hide modal on esc key
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.boundHandleEscape)

    // hide modal when clicking outside (backdrop)
    this.boundHandleBackdrop = this.handleBackdrop.bind(this)
    this.element.addEventListener("click", this.boundHandleBackdrop)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleEscape)
    this.element.removeEventListener("click", this.boundHandleBackdrop)
  }

  show(event) {
    // prevent default link/button behavoir so we dont navigate
    event.preventDefault()
    event.stopPropagation()

    // get data from the elem that was clicked (title, message, url, method)
    const trigger = event.currentTarget
    this.lastTrigger = trigger // Store for focus return

    // rails converts data-* to dataset - https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset
    const title = trigger.dataset.confirmTitle || trigger.getAttribute("data-confirm-title") || "Confirm Action"
    const message = trigger.dataset.confirmMessage || trigger.getAttribute("data-confirm-message") || "Are you sure you want to proceed?"
    const url = trigger.dataset.url || trigger.getAttribute("data-url") || trigger.href || this.confirmUrlValue
    const method = trigger.dataset.method || trigger.getAttribute("data-method") || trigger.dataset.turboMethod || trigger.getAttribute("data-turbo-method") || this.confirmMethodValue || "get"

    // Validate URL
    if (!url || url === "#" || url === window.location.href + "#") {
      console.error("Invalid URL:", url)
      alert("Error: Could not determine action URL. Please refresh the page and try again.")
      return
    }

    // find the actual modal dom node (id=confirmation-modal) - we use this instead of this.element bc the controller might be on the trigger link
    const modalElement = document.getElementById("confirmation-modal")
    if (!modalElement) {
      console.error("Modal element not found in DOM")
      alert("Error: Confirmation modal not found. Please refresh the page.")
      return
    }

    // store url/method on the modal itself so when confirm btn is clicked we can read it (trigger and modal have diff controller instances)
    modalElement.setAttribute("data-confirm-url", url)
    modalElement.setAttribute("data-confirm-method", method)

    // update the title and message text in the modal
    const titleTarget = modalElement.querySelector('[data-confirmation-modal-target="title"]')
    const messageTarget = modalElement.querySelector('[data-confirmation-modal-target="message"]')

    if (titleTarget) {
      titleTarget.textContent = title
    }
    if (messageTarget) {
      messageTarget.textContent = message
    }

    // show modal and lock body scroll
    modalElement.classList.remove("hidden")
    document.body.style.overflow = "hidden" // Prevent background scrolling

    // focus confirm button for accessability (keyboard users)
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
    document.body.style.overflow = "" // restore scrolling

    // return focus to whatever opened the modal
    if (this.lastTrigger) {
      setTimeout(() => {
        this.lastTrigger.focus()
        this.lastTrigger = null
      }, 100)
    }
  }

  confirm() {
    // get url/method from modal (was stored there in show()) - then build a form and submit so we get a proper redirect
    const modalElement = document.getElementById("confirmation-modal")
    if (!modalElement) {
      console.error("Modal element not found")
      this.hide()
      return
    }

    const url = modalElement.dataset.confirmUrl || modalElement.getAttribute("data-confirm-url")
    const method = modalElement.dataset.confirmMethod || modalElement.getAttribute("data-confirm-method") || "get"

    if (!url) {
      console.error("No confirm action stored on modal element")
      console.error("Modal dataset:", modalElement.dataset)
      console.error("Modal getAttribute data-confirm-url:", modalElement.getAttribute("data-confirm-url"))
      this.hide()
      return
    }

    // double check url before we submit
    if (!url || url === "#" || url === window.location.href + "#") {
      console.error("Invalid URL in confirm:", url)
      alert("Error: Invalid action URL. Please refresh the page and try again.")
      this.hide()
      return
    }

    // hide modal first
    this.hide()

    // create a form and submit it (so rails gets a real post with csrf - https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
    const form = document.createElement("form")
    form.method = "post"
    form.action = url
    form.style.display = "none"
    // disable turbo so we get a full page reload and the redirect works (otherwise turbo might intercept)
    form.setAttribute("data-turbo", "false")

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) {
      console.error("CSRF token not found")
      alert("Error: CSRF token not found. Please refresh the page and try again.")
      return
    }

    // add csrf token or rails will reject it
    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = csrfToken
    form.appendChild(csrfInput)

    // add _method for patch/delete (rails convention)
    const methodValue = method ? method.toLowerCase() : "get"
    if (methodValue !== "get" && methodValue !== "post") {
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = methodValue
      form.appendChild(methodInput)
    }

    // append to body then submit (form has to be in dom)
    document.body.appendChild(form)

    // submit - full page reload, server sends redirect
    form.submit()
  }

  submitFormFallback(url, method) {
    // fallback if something went wrong - same idea, build form and submit
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
    // if they clicked the backdrop (not the modal box) close it
    const modalElement = document.getElementById("confirmation-modal")
    if (modalElement && event.target === modalElement) {
      this.hide()
    }
  }
}
