import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    this.sidebar = document.getElementById('sidebar');
    this.overlay = document.getElementById('page-overlay');
    this.menuButton = document.getElementById('menu-toggle-btn');
    this.closeButton = document.getElementById('sidebar-close-btn');

    this.menuButton.addEventListener('click', () => this.open());
    this.closeButton.addEventListener('click', () => this.close());
    this.overlay.addEventListener('click', () => this.close());
  }

  open() {
    this.sidebar.classList.add('is-open');
    this.overlay.classList.add('is-active');
  }

  close() {
    this.sidebar.classList.remove('is-open');
    this.overlay.classList.remove('is-active');
  }
} 