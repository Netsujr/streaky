// import and register all stimulus controllers from controllers/**/*_controller (https://stimulus.hotwired.dev/handbook/installing#using-other-build-systems)
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)
