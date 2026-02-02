import { Controller } from "@hotwired/stimulus"

// Opens habit calendar modal when clicking the card body (not links/buttons).
export default class extends Controller {
  static values = { calendarUrl: String }

  openCalendar(event) {
    if (event.target.closest("a, button, [data-turbo-frame], form")) return
    const url = this.calendarUrlValue
    if (!url) return
    const modal = document.getElementById("habit-calendar-modal")
    const frame = modal?.querySelector("#habit_calendar")
    if (!modal || !frame) return
    frame.src = url
    modal.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }
}
