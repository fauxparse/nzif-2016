module NavigationHelper
  def homepage_link
    name, path = if festival.present?
      [festival.name, festival_path(festival)]
    else
      ["NZIF", root_path]
    end
    link_to name, path, class: "homepage-link"
  end

  def menu_link(text, path, icon, options = {})
    content_tag(:li) do
      link = link_to(path, options) do
        concat icon(icon) unless icon.blank?
        concat content_tag(:span, text)
      end
      concat link
    end
  end
end
