# frozen_string_literal: true

module BlueprintsHelper
  STATUS_BADGES = {
    "draft" => "bg-amber-100 text-amber-800",
    "published" => "bg-emerald-100 text-emerald-700"
  }.freeze

  def blueprint_status_label(status)
    Blueprint::STATUSES[status] || status.to_s.humanize
  end

  def blueprint_status_badge_class(status)
    STATUS_BADGES.fetch(status, "bg-muted text-foreground")
  end

  def blueprint_modality_label(modality)
    Blueprint::MODALITIES[modality] || modality.to_s.upcase
  end
end
