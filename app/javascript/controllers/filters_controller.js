import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 200 }
  }

  connect() {
    this.timeoutId = null
  }

  disconnect() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  submit() {
    clearTimeout(this.timeoutId)
    this.timeoutId = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }
}
