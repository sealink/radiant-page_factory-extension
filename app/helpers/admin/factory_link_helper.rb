module Admin::FactoryLinkHelper
  def link_for(page)
    page.nil? ? new_admin_page_path : new_admin_page_child_path(page)
  end

  def factories
    descendants = PageFactory.descendants.sort { |a,b| a.name <=> b.name }
    [PageFactory, *descendants].map { |p| [p.template_name, p.name] }
  end
end
