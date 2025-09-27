module QuestionsHelper
  include ComponentsHelper

  BUTTON_BASE_CLASSES = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 h-10 px-4 py-2".freeze

  def button_class(variant = :primary)
    variant_class = case variant.to_sym
    when :primary
      ComponentsHelper::PRIMARY_CLASSES
    when :secondary
      ComponentsHelper::SECONDARY_CLASSES
    when :outline
      ComponentsHelper::OUTLINE_CLASSES
    when :ghost
      ComponentsHelper::GHOST_CLASSES
    when :destructive
      ComponentsHelper::DESTRUCTIVE_CLASSES
    else
      ComponentsHelper::PRIMARY_CLASSES
    end

    tw(BUTTON_BASE_CLASSES, variant_class)
  end

  DIFFICULTY_LABELS = {
    "easy" => "Fácil",
    "medium" => "Média",
    "hard" => "Difícil"
  }.freeze

  def difficulty_label(value)
    DIFFICULTY_LABELS.fetch(value, value.to_s.titleize)
  end

  def difficulty_badge_class(value)
    base = "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold"

    palette = {
      "easy" => "border-emerald-200 bg-emerald-50 text-emerald-700",
      "medium" => "border-amber-200 bg-amber-50 text-amber-700",
      "hard" => "border-rose-200 bg-rose-50 text-rose-700"
    }

    tw(base, palette.fetch(value, "border-muted bg-muted/40 text-muted-foreground"))
  end

  def table_container_class
    "w-full overflow-hidden rounded-lg border bg-card text-card-foreground shadow-sm"
  end
end
