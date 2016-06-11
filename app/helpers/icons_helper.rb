module IconsHelper
  def icon(name, options = {})
    options[:class] = [options[:class], "material-icons"].compact.join(" ")
    content_tag :i, name.to_s, options
  end
end
