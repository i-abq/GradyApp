import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "areaSummary"]
  static values = {
    targetQuestions: Number,
    targetPoints: Number
  }

  connect() {
    this.recalculate()
  }

  recalculate() {
    const areaTotals = {}

    this.rowTargets.forEach((row) => {
      const area = row.dataset.area
      if (!area) return

      const quantityInput = row.querySelector("[data-role='quantity']")
      const maxPointsInput = row.querySelector("[data-role='max-points']")
      const pointsPerUnit = row.querySelector("[data-role='points-per-unit']")

      const quantity = this.parseInteger(quantityInput?.value)
      const maxPoints = this.parseFloat(maxPointsInput?.value)

      if (!areaTotals[area]) {
        areaTotals[area] = { quantity: 0, points: 0 }
      }

      areaTotals[area].quantity += quantity
      areaTotals[area].points += maxPoints

      if (pointsPerUnit) {
        const perUnit = quantity > 0 ? maxPoints / quantity : 0
        pointsPerUnit.textContent = perUnit.toFixed(4)
      }
    })

    this.areaSummaryTargets.forEach((container) => {
      const area = container.dataset.area
      if (!area) return

      const summary = areaTotals[area] || { quantity: 0, points: 0 }
      const quantitySpan = container.querySelector("[data-role='total-questions']")
      const pointsSpan = container.querySelector("[data-role='total-points']")
      const deltaQuantitySpan = container.querySelector("[data-role='delta-questions']")
      const deltaPointsSpan = container.querySelector("[data-role='delta-points']")
      const statusBadge = container.querySelector("[data-role='status']")

      const targetQuestions = this.targetQuestionsValue || 0
      const targetPoints = this.targetPointsValue || 0

      const deltaQuestions = targetQuestions - summary.quantity
      const deltaPoints = targetPoints - summary.points

      if (quantitySpan) quantitySpan.textContent = summary.quantity
      if (pointsSpan) pointsSpan.textContent = summary.points.toFixed(4)
      if (deltaQuantitySpan) deltaQuantitySpan.textContent = deltaQuestions
      if (deltaPointsSpan) deltaPointsSpan.textContent = deltaPoints.toFixed(4)

      if (statusBadge) {
        const withinQuestions = deltaQuestions === 0
        const withinPoints = Math.abs(deltaPoints) <= 0.0001
        const ok = withinQuestions && withinPoints

        statusBadge.textContent = ok ? "OK" : "Ajustar"

        statusBadge.classList.remove("bg-emerald-100", "text-emerald-700", "bg-amber-100", "text-amber-800")
        statusBadge.classList.add(
          ok ? "bg-emerald-100" : "bg-amber-100",
          ok ? "text-emerald-700" : "text-amber-800"
        )
      }
    })
  }

  updateTargetQuestions(event) {
    this.targetQuestionsValue = this.parseInteger(event.target.value)
    this.recalculate()
  }

  updateTargetPoints(event) {
    this.targetPointsValue = this.parseFloat(event.target.value)
    this.recalculate()
  }

  parseInteger(value) {
    const parsed = parseInt(value, 10)
    return Number.isFinite(parsed) ? parsed : 0
  }

  parseFloat(value) {
    const parsed = Number.parseFloat(value)
    return Number.isFinite(parsed) ? parsed : 0
  }
}
