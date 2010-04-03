module Admin::PageFactoriesHelper
  def factory_link(factory=PageFactory)
    args = { :factory => factory < PageFactory ? factory : nil }
    @page.nil? ? new_admin_page_path(args) : new_admin_page_child_path(@page, args)
  end
end
