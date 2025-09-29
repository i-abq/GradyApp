import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "panel",
    "trigger",
    "inputs",
    "option",
    "search",
    "summary",
    "checkbox"
  ]

  static values = {
    paramName: String,
    emptyLabel: { type: String, default: "" }
  }

  initialize() {
    this.handlePointerDown = this.handlePointerDown.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.pendingChanges = false
  }

  connect() {
    document.addEventListener("pointerdown", this.handlePointerDown)
    document.addEventListener("keydown", this.handleKeydown)
    this.element.dataset.state = "closed"
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }
    this.syncState()
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.handlePointerDown)
    document.removeEventListener("keydown", this.handleKeydown)
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

  open() {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.remove("hidden")
    }
    this.element.dataset.state = "open"
    this.pendingChanges = false
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }

    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
      this.filterOptions({ target: this.searchTarget })
      requestAnimationFrame(() => {
        this.searchTarget.focus()
      })
    }
  }

  close({ submit = true } = {}) {
    if (this.hasPanelTarget) {
      this.panelTarget.classList.add("hidden")
    }
    this.element.dataset.state = "closed"
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }

    if (submit && this.pendingChanges) {
      const shouldSubmit = this.pendingChanges
      this.pendingChanges = false
      if (shouldSubmit) {
        this.submitForm()
      }
    }
  }

  isOpen() {
    return this.element.dataset.state === "open"
  }

  handlePointerDown(event) {
    if (!this.isOpen()) return
    if (this.element.contains(event.target)) return
    this.close()
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen()) {
      event.preventDefault()
      this.close()
      this.triggerTarget?.focus()
    }
  }

  filterOptions(event) {
    if (!event || !event.target) return
    const query = event.target.value.trim().toLowerCase()

    this.optionTargets.forEach((option) => {
      const text = option.dataset.search || ""
      const matches = query === "" || text.includes(query)
      option.classList.toggle("hidden", !matches)
    })
  }

  onCheckboxChange(event) {
    event.stopPropagation()
    this.pendingChanges = true
    this.syncHiddenInputs()
    this.updateSummary()
  }

  syncState() {
    this.syncHiddenInputs()
    this.updateSummary()
  }

  syncHiddenInputs() {
    if (!this.hasInputsTarget) return

    this.inputsTarget.innerHTML = ""

    this.checkboxTargets
      .filter((checkbox) => checkbox.checked)
      .forEach((checkbox) => {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = `${this.paramNameValue}[]`
        input.value = checkbox.value
        input.dataset.value = checkbox.value
        this.inputsTarget.appendChild(input)
      })
  }

  updateSummary() {
    if (!this.hasSummaryTarget) return

    const selected = this.checkboxTargets.filter((checkbox) => checkbox.checked)
    let summary

    if (selected.length === 0) {
      summary = this.emptyLabelValue || "Todos"
    } else if (selected.length <= 2) {
      summary = selected.map((checkbox) => checkbox.dataset.label).join(", ")
    } else {
      summary = `${selected.length} selecionadas`
    }

    this.summaryTarget.textContent = summary
  }

  submitForm() {
    const form = this.element.closest("form")
    if (!form) return

    const filtersController = this.application.getControllerForElementAndIdentifier(
      form,
      "filters"
    )

    if (filtersController && typeof filtersController.submit === "function") {
      filtersController.submit()
    } else {
      form.requestSubmit()
    }
  }
}
