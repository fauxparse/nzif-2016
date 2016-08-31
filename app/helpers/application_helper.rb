module ApplicationHelper
  def hide_footer!
    @hide_footer = true
  end

  def hide_footer?
    !!@hide_footer
  end
end
