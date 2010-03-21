module Admin::FactoryLinkHelper
  def link_for(page)
    page.nil? ? new_admin_page_path : new_admin_page_child_path(page)
  end

  def factories
    [PageFactory, *PageFactory.descendants].map &:name
  end
end
