import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "input", "label", "option", "trigger"]
  static values = {
    defaultLabel: String
  }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
    document.addEventListener("keydown", this.boundHandleKeydown)
    this.updateLabel()
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    if (this.isOpen()) {
      this.close()
    } else {
      this.open()
    }
  }

  select(event) {
    event.preventDefault()
    const { value, label } = event.currentTarget.dataset
    this.inputTarget.value = value
    this.labelTarget.textContent = label || this.defaultLabel()
    this.close()
    this.updateLabel()
    this.submitForm()
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.element.dataset.state = "open"
    this.triggerTarget?.setAttribute("aria-expanded", "true")
  }

  close() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("hidden")
    }
    delete this.element.dataset.state
    this.triggerTarget?.setAttribute("aria-expanded", "false")
  }

  isOpen() {
    return this.element.dataset.state === "open"
  }

  handleClickOutside(event) {
    if (!this.isOpen()) return
    if (this.element.contains(event.target)) return
    this.close()
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      this.close()
      this.triggerTarget?.focus()
    }
  }

  updateLabel() {
    const value = this.inputTarget.value || ""
    let label = this.defaultLabel()

    this.optionTargets.forEach((option) => {
      const optionValue = option.dataset.value || ""
      const selectedClass = option.dataset.selectedClass || ""
      const isActive = optionValue === value
      option.dataset.state = isActive ? "active" : "inactive"
      option.setAttribute("aria-pressed", isActive)

      selectedClass
        .split(" ")
        .filter(Boolean)
        .forEach((klass) => {
          option.classList.toggle(klass, isActive)
        })

      if (isActive) {
        label = option.dataset.label || label
      }
    })

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = label
    }
  }

  submitForm() {
    const form = this.element.closest("form")
    if (form) form.requestSubmit()
  }

  defaultLabel() {
    return this.hasDefaultLabelValue ? this.defaultLabelValue : ""
  }
}
