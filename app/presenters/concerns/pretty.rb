module Pretty
  extend ActiveSupport::Concern

  def pretty(raw)
    markdown.render(raw || "").html_safe
  end

  private

  class HTMLWithSmartypants < Redcarpet::Render::HTML
    include Redcarpet::Render::SmartyPants
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(HTMLWithSmartypants)
  end
end
