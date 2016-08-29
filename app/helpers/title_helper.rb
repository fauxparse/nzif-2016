module TitleHelper
  def title_tag
    title = [
      content_for(:title),
      festival.try(:name)
    ].compact.join(' ┊ ')
    content_tag :title, title
  end
end
