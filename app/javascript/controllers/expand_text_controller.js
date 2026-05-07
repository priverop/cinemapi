import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="expand-text"
export default class extends Controller {
  static targets = ["text", "button"]

  toggle() {
    const expanded = this.textTarget.classList.toggle("line-clamp-3")
    this.buttonTarget.textContent = expanded ? "Read more" : "Read less"
  }
}
