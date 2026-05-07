import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapse-filters"
// Keeps <details> open on desktop (≥breakpoint), collapsed by default on mobile.
export default class extends Controller {
  static values = { breakpoint: { type: Number, default: 768 } }

  connect() {
    this.update()
    this._listener = this.update.bind(this)
    window.addEventListener("resize", this._listener)
  }

  disconnect() {
    window.removeEventListener("resize", this._listener)
  }

  update() {
    if (window.innerWidth >= this.breakpointValue) {
      this.element.open = true
    }
  }
}
