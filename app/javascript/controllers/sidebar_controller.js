import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["panel", "overlay"]

  connect() {
    // Optional: close sidebar with the escape key
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.boundCloseOnEscape)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundCloseOnEscape)
  }

  toggle() {
    this.panelTarget.classList.toggle("active")
    this.overlayTarget.classList.toggle("active")
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.panelTarget.classList.contains("active")) {
      this.toggle()
    }
  }
} 