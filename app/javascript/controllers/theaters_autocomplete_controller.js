import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theaters-autocomplete"
export default class extends Controller {
  static targets = ["input", "results", "pills", "template"]
  static values = { url: String }

  connect() {
    this.selected = new Set(
      Array.from(this.pillsTarget.querySelectorAll("input[type=hidden]"))
           .map(pill => pill.value)
    )
  }

  search() {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => this.fetchResults(), 250)
  }

  async fetchResults() {
    const query = this.inputTarget.value.trim()
    if (query.length < 3) { this.hideResults(); return }

    const response = await fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" }
    })

    const theaters = await response.json()
    this.renderResults(theaters)
  }

  renderResults(theaters) {
    const ul = this.resultsTarget
    ul.innerHTML = ""

    const available = theaters.filter(t => !this.selected.has(t.name))

    if (available.length === 0) { ul.classList.add("hidden"); return }

    available.forEach(t => {
      const li = document.createElement("li")
      li.textContent = t.name                                                                                                                                                                                                           
      li.className = "px-3 py-2 text-sm cursor-pointer hover:bg-blue-50 dark:hover:bg-gray-600"
      li.addEventListener("mousedown", (e) => {                                                                                                                                                                                         
        e.preventDefault()                                                                                                                                                                                                              
        this.addPill(t.name)                                                                                                                                                                                                            
      })                                                                                                                                                                                                                                
      ul.appendChild(li)
    })
    ul.classList.remove("hidden")
  }

  addPill(name) {
    if (this.selected.has(name)) return
    this.selected.add(name)

    const fragment = this.templateTarget.content.cloneNode(true)
    fragment.querySelector("[data-pill-name]").textContent = name
    fragment.querySelector("button").dataset.name = name
    fragment.querySelector("input[type=hidden]").value = name
    this.pillsTarget.appendChild(fragment)

    this.inputTarget.value = ""
    this.hideResults()
    this.dispatchChange()
  }

  removePill(event) {
    const name = event.currentTarget.dataset.name
    this.selected.delete(name)
    event.currentTarget.closest("span").remove()
    this.dispatchChange()
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden")
  }

  dispatchChange() {
    this.element.closest("form")?.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
