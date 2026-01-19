import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameField", "nameError"]

  validateName() {
    const name = this.nameFieldTarget.value
    const maxLength = 60

    if (name.length > maxLength) {
      this.showError(`Name must be ${maxLength} characters or less`)
    } else if (name.length === 0) {
      this.hideError()
    } else {
      this.hideError()
    }
  }

  showError(message) {
    if (this.hasNameErrorTarget) {
      this.nameErrorTarget.textContent = message
      this.nameErrorTarget.classList.remove("hidden")
      this.nameFieldTarget.classList.add("border-red-500")
      this.nameFieldTarget.classList.remove("border-gray-300")
    }
  }

  hideError() {
    if (this.hasNameErrorTarget) {
      this.nameErrorTarget.classList.add("hidden")
      this.nameFieldTarget.classList.remove("border-red-500")
      this.nameFieldTarget.classList.add("border-gray-300")
    }
  }
}
