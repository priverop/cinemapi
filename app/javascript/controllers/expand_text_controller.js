import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expand-text"
export default class extends Controller {
  static targets = ["text", "button"]

  connect() {
    this._check = this._updateButtonVisibility.bind(this)
    this._updateButtonVisibility()
    window.addEventListener("resize", this._check)
  }

  disconnect() {
    window.removeEventListener("resize", this._check)
  }

  toggle() {
    const expanded = this.textTarget.classList.toggle("line-clamp-3")
    this.buttonTarget.textContent = expanded ? "Read more" : "Read less"
    this._updateButtonVisibility()
  }

  _updateButtonVisibility() {
    const clamped = this.textTarget.classList.contains("line-clamp-3")
    const overflows = this.textTarget.scrollHeight > this.textTarget.clientHeight
    this.buttonTarget.hidden = clamped && !overflows
  }
}
