import { Application } from "@hotwired/stimulus"

const application = Application.start()

// configure stimulus - turn debug on for dev if things get weird https://stimulus.hotwired.dev/reference/application
application.debug = false
window.Stimulus   = application

export { application }
