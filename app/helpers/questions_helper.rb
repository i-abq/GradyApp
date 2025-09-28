module QuestionsHelper
  include ComponentsHelper

  BUTTON_BASE_CLASSES = "btn btn-sm".freeze

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
    "w-full overflow-hidden rounded-lg border border-border bg-card text-card-foreground"
  end

  def filter_dropdown(form, param, label:, options:, current_value:, all_label: "Todas")
    normalized_current = current_value.to_s
    normalized_options = [[all_label, ""]] + options.map { |option_label, option_value| [option_label, option_value.to_s] }
    selected_label = normalized_options.find { |_, value| value == normalized_current }&.first || all_label

    content_tag :div, class: "relative", data: { controller: "filter", filter_default_label_value: all_label } do
      form.hidden_field(param, value: normalized_current, data: { filter_target: "input" }) +
        button_tag(type: :button, class: "btn btn-outline btn-sm relative gap-2 pr-8 text-left justify-start", data: { filter_target: "trigger", action: "click->filter#toggle" }) do
          safe_join([
            content_tag(:div, class: "flex flex-col items-start") do
              content_tag(:span, label, class: "text-xs text-muted-foreground") +
                content_tag(:span, selected_label, class: "text-sm font-medium text-foreground", data: { filter_target: "label" })
            end,
            content_tag(:span, "▾", class: "pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground")
          ])
        end +
        content_tag(:div, class: "absolute left-0 z-30 mt-2 w-56 rounded-md border border-border bg-popover p-2 hidden", data: { filter_target: "panel" }) do
          safe_join(
            normalized_options.map do |option_label, option_value|
              selected = option_value == normalized_current
              classes = [
                "flex w-full items-center justify-between rounded-md px-3 py-2 text-left text-sm text-foreground transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              ]
              classes << "bg-accent text-accent-foreground" if selected

              button_tag option_label,
                         type: :button,
                         class: classes.join(" "),
                         data: {
                           filter_target: "option",
                           action: "filter#select",
                           value: option_value,
                           label: option_label,
                           selected_class: "bg-accent text-accent-foreground"
                         }
            end
          )
        end
    end
  end
end
