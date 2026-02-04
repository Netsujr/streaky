# helpers for views. habit_color_hex maps habit color name to tailwind 500 hex so swatches render (dynamic bg-* classes get purged).
module ApplicationHelper
  HABIT_COLOR_HEX = {
    "blue" => "#3b82f6",
    "green" => "#22c55e",
    "purple" => "#a855f7",
    "red" => "#ef4444",
    "orange" => "#f97316",
    "yellow" => "#eab308",
    "pink" => "#ec4899",
    "indigo" => "#6366f1"
  }.freeze

  def habit_color_hex(color_name)
    return nil if color_name.blank?
    HABIT_COLOR_HEX[color_name.to_s.downcase]
  end
end
