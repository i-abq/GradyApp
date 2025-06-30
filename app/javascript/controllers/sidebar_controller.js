import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  open() {
    this.sidebarTarget.classList.add('is-open');
    this.overlayTarget.classList.add('is-active');
  }

  close() {
    this.sidebarTarget.classList.remove('is-open');
    this.overlayTarget.classList.remove('is-active');
  }
} 