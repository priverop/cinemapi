import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { url: String };

  navigate(event) {
    if (event.target.closest("a, form")) return;

    window.location = this.urlValue;
  }
}
