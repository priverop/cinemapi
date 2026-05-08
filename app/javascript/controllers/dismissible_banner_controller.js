import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismissible-banner"
// Hides banner permanently via localStorage key.
export default class extends Controller {
  static values = { key: String }

  connect() {
    if (localStorage.getItem(this.keyValue) === "1") {
      this.element.remove()
    }
  }

  dismiss() {
    localStorage.setItem(this.keyValue, "1")
    this.element.remove()
  }
}
