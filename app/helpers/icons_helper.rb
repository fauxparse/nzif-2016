module IconsHelper
  def icon(name)
    content_tag :i, name.to_s, class: "material-icons"
  end
end
