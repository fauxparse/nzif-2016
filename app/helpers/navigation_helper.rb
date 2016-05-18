module NavigationHelper
  def homepage_link
    name, path = if festival.present?
      [festival.name, festival_path(festival)]
    else
      ["NZIF", root_path]
    end
    link_to name, path, class: "homepage-link"
  end
end
