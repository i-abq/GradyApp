import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "message", "icon"]

  connect() {
    this.preventDefaults = this.preventDefaults.bind(this)
    this.highlight = this.highlight.bind(this)
    this.unhighlight = this.unhighlight.bind(this)
    this.dropHandler = this.dropHandler.bind(this)

    this.element.addEventListener("dragover", this.preventDefaults, false)
    this.element.addEventListener("dragenter", this.highlight, false)
    this.element.addEventListener("dragleave", this.unhighlight, false)
    this.element.addEventListener("drop", this.dropHandler, false)
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.preventDefaults, false)
    this.element.removeEventListener("dragenter", this.highlight, false)
    this.element.removeEventListener("dragleave", this.unhighlight, false)
    this.element.removeEventListener("drop", this.dropHandler, false)
  }

  preventDefaults(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  highlight(event) {
    this.preventDefaults(event)
    this.element.classList.add("border-primary/60", "bg-muted/70")
  }

  unhighlight(event) {
    this.preventDefaults(event)
    this.element.classList.remove("border-primary/60", "bg-muted/70")
  }

  trigger() {
    this.fileInputTarget.click()
  }

  dropHandler(event) {
    this.unhighlight(event)
    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.setFile(files[0])
    }
  }

  changed(event) {
    const files = event.target.files
    if (files.length > 0) {
      this.setFile(files[0])
    }
  }

  setFile(file) {
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.fileInputTarget.files = dataTransfer.files

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = file.name
      this.messageTarget.classList.remove("text-muted-foreground")
      this.messageTarget.classList.add("text-foreground")
    }

    if (this.hasIconTarget) {
      this.iconTarget.classList.add("text-primary")
    }
  }
}
