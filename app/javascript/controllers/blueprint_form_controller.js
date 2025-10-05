import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["areas", "area", "components", "component", "pointsPerItem"]
  static values = {
    areaIndex: { type: Number, default: 0 }
  }

  connect() {
    if (this.areaTargets.length > this.areaIndexValue) {
      this.areaIndexValue = this.areaTargets.length
    }
    this.updatePositions()
  }

  addArea(event) {
    event.preventDefault()
    const template = this.areaTemplateHTML
    const areaIndex = this.generateUid()
    const html = template.replace(/NEW_AREA/g, areaIndex)
    this.areasTarget.insertAdjacentHTML("beforeend", html)
    this.areaIndexValue += 1
    this.updatePositions()
  }

  removeArea(event) {
    event.preventDefault()
    const areaElement = event.currentTarget.closest('[data-blueprint-form-target="area"]')
    if (!areaElement) return

    const destroyField = areaElement.querySelector('input[name$="[_destroy]"]')
    if (destroyField && destroyField.value !== "1") {
      const isNew = areaElement.dataset.newRecord === "true"
      if (isNew) {
        areaElement.remove()
      } else {
        destroyField.value = "1"
        areaElement.classList.add("hidden")
      }
      this.updatePositions()
    }
  }

  addComponent(event) {
    event.preventDefault()
    const areaElement = event.currentTarget.closest('[data-blueprint-form-target="area"]')
    if (!areaElement) return

    const templateElement = areaElement.querySelector('template[data-component-template]')
    if (!templateElement) return

    const componentContainer = areaElement.querySelector('[data-blueprint-form-target="components"]')
    const htmlTemplate = templateElement.innerHTML
    const componentIndex = this.generateUid()
    const areaIndex = areaElement.dataset.areaIndex
    let html = htmlTemplate.replace(/NEW_COMPONENT/g, componentIndex)
    html = html.replace(/NEW_AREA/g, areaIndex)
    componentContainer.insertAdjacentHTML("beforeend", html)
    this.updatePositions(areaElement)
  }

  removeComponent(event) {
    event.preventDefault()
    const componentElement = event.currentTarget.closest('[data-blueprint-form-target="component"]')
    if (!componentElement) return

    const destroyField = componentElement.querySelector('input[name$="[_destroy]"]')
    if (destroyField && destroyField.value !== "1") {
      const isNew = componentElement.dataset.newRecord === "true"
      if (isNew) {
        componentElement.remove()
      } else {
        destroyField.value = "1"
        componentElement.classList.add("hidden")
      }
      const areaElement = componentElement.closest('[data-blueprint-form-target="area"]')
      this.updatePositions(areaElement)
    }
  }

  recalculate(event) {
    const componentElement = event.target.closest('[data-blueprint-form-target="component"]')
    if (!componentElement) return

    const numItemsField = componentElement.querySelector('input[name$="[num_items]"]')
    const maxScoreField = componentElement.querySelector('input[name$="[maximum_score]"]')
    const pointsElement = componentElement.querySelector('[data-blueprint-form-target="pointsPerItem"]')

    const numItems = parseFloat(numItemsField?.value || "0")
    const maxScore = parseFloat(maxScoreField?.value || "0")

    let result = 0
    if (numItems > 0) {
      result = maxScore / numItems
    }

    if (pointsElement) {
      pointsElement.textContent = Number.isFinite(result) ? result.toFixed(3) : "0.000"
    }
  }

  get areaTemplateHTML() {
    if (!this._areaTemplateHTML) {
      const template = this.element.querySelector('template[data-blueprint-form-target="areaTemplate"]')
      this._areaTemplateHTML = template.innerHTML.trim()
    }
    return this._areaTemplateHTML
  }

  updatePositions(areaElement = null) {
    const areaElements = areaElement ? [areaElement] : this.areaTargets.filter((element) => {
      const destroyField = element.querySelector('input[name$="[_destroy]"]')
      return destroyField && destroyField.value !== "1"
    })

    if (!areaElement)
      areaElements.forEach((element, index) => {
        const positionField = element.querySelector('input[name$="[position]"]')
        if (positionField) positionField.value = index
        this.updateComponentPositions(element)
      })
    else
      this.updateComponentPositions(areaElement)
  }

  updateComponentPositions(areaElement) {
    const components = Array.from(areaElement.querySelectorAll('[data-blueprint-form-target="component"]')).filter((element) => {
      const destroyField = element.querySelector('input[name$="[_destroy]"]')
      return destroyField && destroyField.value !== "1"
    })

    components.forEach((component, index) => {
      const positionField = component.querySelector('input[name$="[position]"]')
      if (positionField) positionField.value = index
    })
  }

  generateUid() {
    return `uid_${Date.now()}_${Math.floor(Math.random() * 1_000_000)}`
  }
}
