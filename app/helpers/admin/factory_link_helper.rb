module Admin::FactoryLinkHelper
  def factory_link_for(page)
    page.nil? ? new_admin_page_path : new_admin_page_child_path(page)
  end

  def factory_options
    descendants = PageFactory.descendants.sort { |a,b| a.name <=> b.name }
    factories = descendants.map { |p| [p.template_name, p.name] }
    factories.unshift ['Page', nil]
    options_for_select factories, 'PageFactory'
  end
end
