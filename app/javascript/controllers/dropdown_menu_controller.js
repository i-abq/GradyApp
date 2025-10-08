import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "trigger"]

  connect() {
    this.hide = this.hide.bind(this)
    this.handleKeyup = this.handleKeyup.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove("hidden")
    document.addEventListener("click", this.hide)
    document.addEventListener("keyup", this.handleKeyup)
  }

  hide(event) {
    if (event && this.element.contains(event.target)) return

    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.hide)
    document.removeEventListener("keyup", this.handleKeyup)
  }

  handleKeyup(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }

  select() {
    this.hide()
  }

  disconnect() {
    document.removeEventListener("click", this.hide)
    document.removeEventListener("keyup", this.handleKeyup)
  }
}
