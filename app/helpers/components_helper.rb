require "tailwind_merge"

module ComponentsHelper
  def tw(*classes)
    TailwindMerge::Merger.new.merge(classes.compact.join(" "))
  end

  PRIMARY_CLASSES = "btn-primary"
  SECONDARY_CLASSES = "btn-secondary"
  OUTLINE_CLASSES = "btn-outline"
  GHOST_CLASSES = "btn-ghost"
  DESTRUCTIVE_CLASSES = "btn-destructive"

  module Button
    PRIMARY = ComponentsHelper::PRIMARY_CLASSES
    SECONDARY = ComponentsHelper::SECONDARY_CLASSES
    OUTLINE = ComponentsHelper::OUTLINE_CLASSES
    GHOST = ComponentsHelper::GHOST_CLASSES
    DESTRUCTIVE = ComponentsHelper::DESTRUCTIVE_CLASSES
  end

  module Alert
  end
end
