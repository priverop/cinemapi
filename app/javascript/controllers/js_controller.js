import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { loaded: Boolean }

  connect() {
    this.loadedValue = true
  }
}
