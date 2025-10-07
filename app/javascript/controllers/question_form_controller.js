import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "questionType",
    "mcqSection",
    "openSection",
    "area",
    "theme",
    "correctToggle",
    "tagsInput"
  ]

  static values = {
    themes: Object
  }

  connect() {
    this.updateType()
    this.updateThemes()
  }

  changeType() {
    this.updateType()
  }

  changeArea() {
    this.updateThemes()
  }

  markCorrect(event) {
    if (!event.currentTarget.checked) return

    this.correctToggleTargets.forEach((checkbox) => {
      if (checkbox !== event.currentTarget) {
        checkbox.checked = false
      }
    })
  }

  updateType() {
    const type = this.questionTypeTarget?.value
    const showMcq = type === "mcq5_unica"

    if (this.hasMcqSectionTarget) {
      this.mcqSectionTarget.classList.toggle("hidden", !showMcq)
    }

    if (this.hasOpenSectionTarget) {
      this.openSectionTarget.classList.toggle("hidden", showMcq)
    }
  }

  updateThemes() {
    if (!this.hasAreaTarget || !this.hasThemeTarget) return

    const area = this.areaTarget.value
    const themesForArea = this.themesValue?.[area] || []
    const currentValue = this.themeTarget.value

    while (this.themeTarget.firstChild) {
      this.themeTarget.removeChild(this.themeTarget.firstChild)
    }

    themesForArea.forEach(({ label, value }) => {
      const option = document.createElement("option")
      option.value = value
      option.textContent = label
      this.themeTarget.appendChild(option)
    })

    const stillExists = themesForArea.some(({ value }) => value === currentValue)
    if (stillExists) {
      this.themeTarget.value = currentValue
    }
  }
}
