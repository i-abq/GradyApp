module ApplicationHelper
  include ComponentsHelper

  def pagination_button(path_helper:, params:, page:, icon:, label:, disabled: false)
    classes = tw("btn btn-outline btn-sm h-9 w-9 p-0", ("pointer-events-none opacity-50" if disabled))
    icon_tag = image_tag(icon, alt: "", class: "h-4 w-4", aria: { hidden: true })
    inner = safe_join([icon_tag, content_tag(:span, label, class: "sr-only")])

    if disabled
      content_tag(:span, inner, class: classes, role: "button", aria: { label: label, disabled: "true" })
    else
      link_to inner, path_helper.call(params.merge(page: page).compact_blank), class: classes, aria: { label: label }
    end
  end

  def pagination_base_params(filters)
    filters.each_with_object({}) do |(key, value), acc|
      case value
      when Array
        acc[key] = value.presence
      else
        acc[key] = value.presence
      end
    end.compact_blank
  end

  def table_container_class
    "w-full overflow-hidden rounded-lg border border-border bg-card text-card-foreground"
  end
end
