import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step",
    "indicator",
    "currentStepField",
    "previousButton",
    "nextButton",
    "finalActions"
  ]

  static values = {
    current: Number
  }

  connect() {
    this.totalSteps = this.stepTargets.length

    if (!this.hasCurrentValue || this.currentValue < 1 || this.currentValue > this.totalSteps) {
      this.currentValue = this.initialStep()
    }

    this.render()
  }

  next(event) {
    event.preventDefault()
    if (this.currentValue >= this.totalSteps) return

    this.currentValue += 1
    this.render()
  }

  previous(event) {
    event.preventDefault()
    if (this.currentValue <= 1) return

    this.currentValue -= 1
    this.render()
  }

  go(event) {
    event.preventDefault()
    const step = Number(event.currentTarget.dataset.wizardStepValue)

    if (!Number.isFinite(step)) return

    this.currentValue = Math.min(Math.max(step, 1), this.totalSteps)
    this.render()
  }

  render() {
    this.showCurrentStep()
    this.highlightIndicators()
    this.updateNavigation()
    this.syncHiddenField()
  }

  showCurrentStep() {
    this.stepTargets.forEach((element, index) => {
      const stepNumber = index + 1
      if (stepNumber === this.currentValue) {
        element.classList.remove("hidden")
      } else {
        element.classList.add("hidden")
      }
    })
  }

  highlightIndicators() {
    this.indicatorTargets.forEach((indicator, index) => {
      const stepNumber = index + 1
      indicator.dataset.state = stepNumber === this.currentValue ? "active" : stepNumber < this.currentValue ? "complete" : "pending"

      indicator.classList.remove("bg-primary", "text-white", "border-primary", "bg-muted", "text-muted-foreground")

      if (indicator.dataset.state === "active") {
        indicator.classList.add("bg-primary", "text-white")
      } else if (indicator.dataset.state === "complete") {
        indicator.classList.add("border", "border-primary")
      } else {
        indicator.classList.add("bg-muted", "text-muted-foreground")
      }

      indicator.setAttribute("aria-current", indicator.dataset.state === "active" ? "step" : "false")
    })
  }

  updateNavigation() {
    if (this.hasPreviousButtonTarget) {
      this.previousButtonTarget.disabled = this.currentValue <= 1
      this.toggleHidden(this.previousButtonTarget, this.currentValue <= 1)
    }

    if (this.hasNextButtonTarget) {
      const isLast = this.currentValue >= this.totalSteps
      this.nextButtonTarget.disabled = isLast
      this.toggleHidden(this.nextButtonTarget, isLast)
    }

    if (this.hasFinalActionsTarget) {
      const isLast = this.currentValue >= this.totalSteps
      this.toggleHidden(this.finalActionsTarget, !isLast)
    }
  }

  syncHiddenField() {
    if (this.hasCurrentStepFieldTarget) {
      this.currentStepFieldTarget.value = this.currentValue
    }
  }

  toggleHidden(element, shouldHide) {
    element.classList.toggle("hidden", shouldHide)
  }

  initialStep() {
    if (this.hasCurrentStepFieldTarget) {
      const parsed = Number(this.currentStepFieldTarget.value)
      if (Number.isFinite(parsed) && parsed >= 1 && parsed <= this.totalSteps) {
        return parsed
      }
    }

    return 1
  }
}
