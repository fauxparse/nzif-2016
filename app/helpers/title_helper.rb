module TitleHelper
  def title_tag
    title = [
      content_for(:title),
      festival.try(:name)
    ].compact.join(' ┊ ').html_safe
    content_tag :title, title
  end
end
