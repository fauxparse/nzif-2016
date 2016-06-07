module Admin::MenuHelper
  def admin_menu(name, options = {}, &block)
    options[:"data-menu-name"] = name
    selected = options[:"aria-selected"] = options.delete(:selected) ||
      controller_name == name.to_s.pluralize
    label = options.delete(:label) || t("admin.menu.#{name}.index")
    path = options.delete(:path) || send(:"admin_#{name}_path", festival)
    icon = options.delete(:icon) || :web_asset

    content_tag(:li, options) do
      concat admin_menu_item(label, path, icon, false)
      concat content_tag(:ul, &block) if block_given? && selected
    end
  end

  def admin_menu_item(label, path, icon = nil, include_list_item = true)
    link = link_to(path) do
      concat icon(icon) if icon.present?
      concat content_tag(:span, label)
    end

    include_list_item ?  content_tag(:li, link) : link
  end
end
