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

  STATUS_BADGE_CLASSES = {
    "draft" => "bg-amber-100 text-amber-800",
    "review" => "bg-blue-100 text-blue-800",
    "approved" => "bg-emerald-100 text-emerald-700",
    "retired" => "bg-slate-100 text-slate-600"
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

  def question_status_badge(question)
    content_tag :span,
                question.status_label,
                class: tw("rounded-full px-2 py-0.5 text-xs font-medium", STATUS_BADGE_CLASSES.fetch(question.status, "bg-muted text-muted-foreground"))
  end

  def question_area_label(question)
    Blueprint::AREAS.dig(question.area, :label) || question.area.to_s.humanize
  end

  def question_theme_label(question)
    Blueprint::AREAS.dig(question.area, :components, question.theme, :label) || question.theme.to_s.humanize
  end


  def single_filter_dropdown(form, param, label:, options:, current_value:, all_label: "Todas")
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

  def multi_filter_dropdown(form, param:, label:, options:, selected_values:, counts:, all_label: "Todas")
    normalized_selected = Array(selected_values).map(&:to_s)
    options_with_values = options.map { |option_label, option_value| [option_label, option_value.to_s] }
    panel_id = "#{param}-filter-panel"
    trigger_id = "#{param}-filter-trigger"

    summary_text = if normalized_selected.empty?
      all_label
    elsif normalized_selected.length <= 2
      labels_for_values(normalized_selected, options_with_values).join(", ")
    else
      "#{normalized_selected.length} selecionadas"
    end

    counts = counts || {}

    content_tag :div, class: "relative", data: {
      controller: "multi-filter",
      "multi-filter-param-name-value": param,
      "multi-filter-empty-label-value": all_label
    } do
      hidden_inputs = content_tag(:div, data: { "multi-filter-target": "inputs" }) do
        safe_join(normalized_selected.map { |value| form.hidden_field("#{param}[]", value: value, id: nil, data: { value: value }) })
      end

      trigger_button = button_tag type: :button,
                                  class: tw("btn btn-outline btn-sm relative w-full gap-3 pr-9 text-left justify-start border-dotted border-border"),
                                  id: trigger_id,
                                  data: { "multi-filter-target": "trigger", action: "click->multi-filter#toggle" },
                                  aria: { expanded: "false", controls: panel_id } do
        safe_join([
          content_tag(:span, class: "flex items-center gap-2") do
            safe_join([
              image_tag("icons/circle-plus-icon.svg", alt: "", class: "h-4 w-4"),
              content_tag(:span, label, class: "text-sm font-medium text-foreground")
            ])
          end,
          content_tag(:span, summary_text, class: "text-xs text-muted-foreground", data: { "multi-filter-target": "summary" }),
          content_tag(:span, "▾", class: "pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground")
        ])
      end

      search_input = content_tag(:div, class: "relative mb-2") do
        icon = content_tag(:span, class: "pointer-events-none absolute inset-y-0 left-3 flex items-center text-muted-foreground") do
          inline_search_icon
        end

        input = text_field_tag nil, "",
                               placeholder: "Filtrar opções...",
                               class: "input h-9 w-full border border-border pl-9 text-sm focus-visible:ring-0 focus-visible:border-border",
                               data: { "multi-filter-target": "search", action: "input->multi-filter#filterOptions" },
                               autocomplete: "off"

        safe_join([icon, input])
      end

      options_list = content_tag(:div, class: "space-y-1 max-h-64 overflow-y-auto", data: { "multi-filter-target": "options" }) do
        safe_join(
          options_with_values.map do |option_label, option_value|
            selected = normalized_selected.include?(option_value)
            option_count = counts[option_value] || 0

            content_tag :label,
                        class: tw("flex items-center gap-3 rounded-md px-3 py-2 text-sm text-foreground transition-colors cursor-pointer select-none hover:bg-accent hover:text-accent-foreground"),
                        data: {
                          "multi-filter-target": "option",
                          value: option_value,
                          label: option_label,
                          search: option_label.downcase
                        } do
              checkbox = check_box_tag "", option_value, selected,
                                        name: nil,
                                        class: "checkbox",
                                        data: {
                                          "multi-filter-target": "checkbox",
                                          label: option_label,
                                          action: "change->multi-filter#onCheckboxChange"
                                        }

              label_span = content_tag(:span, option_label, class: "flex-1 text-sm")
              count_badge = content_tag(:span, option_count, class: "ml-auto rounded-md px-2 py-0.5 text-xs font-medium text-muted-foreground")

              safe_join([checkbox, label_span, count_badge])
            end
          end
        )
      end

      clear_button = button_tag "Limpar filtros",
                                type: :button,
                                class: "btn btn-ghost btn-sm w-full justify-center text-xs text-muted-foreground",
                                data: { action: "multi-filter#clear" }

      panel = content_tag(:div,
                          class: "absolute left-0 z-30 mt-2 w-64 rounded-md border border-border bg-popover p-3 shadow-sm hidden",
                          id: panel_id,
                          role: "dialog",
                          aria: { labelledby: trigger_id, modal: "false" },
                          data: { "multi-filter-target": "panel" }) do
        safe_join([search_input, options_list, clear_button])
      end

      safe_join([hidden_inputs, trigger_button, panel])
    end
  end

  private

  def labels_for_values(selected_values, options)
    index = options.each_with_object({}) do |(option_label, option_value), acc|
      acc[option_value] = option_label
    end
    selected_values.map { |value| index[value] }.compact
  end

  def inline_search_icon
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", class: "h-4 w-4") do
      safe_join([
        content_tag(:circle, nil, cx: "11", cy: "11", r: "8"),
        content_tag(:path, nil, d: "m21 21-3.5-3.5")
      ])
    end
  end
end
