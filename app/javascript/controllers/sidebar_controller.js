import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay", "menuIcon", "closeIcon"]

  connect() {
    // Ensure the close icon is hidden by default
    this.closeIconTarget.classList.add('hidden');
  }

  toggle() {
    const isOpen = this.sidebarTarget.classList.toggle('is-open');
    this.overlayTarget.classList.toggle('is-active', isOpen);

    // Toggle icon visibility based on the sidebar's state
    this.menuIconTarget.classList.toggle('hidden', isOpen);
    this.closeIconTarget.classList.toggle('hidden', !isOpen);
  }

  close() {
    // This method is called by the overlay
    this.sidebarTarget.classList.remove('is-open');
    this.overlayTarget.classList.remove('is-active');

    // Always reset icons to the "closed" state
    this.menuIconTarget.classList.remove('hidden');
    this.closeIconTarget.classList.add('hidden');
  }
} 