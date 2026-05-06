import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const root = document.documentElement
    const isDark = root.classList.toggle("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
  }
}
