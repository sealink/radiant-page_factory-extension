require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_factory"
  
  def activate
    Page.send :include, PageFactory::PageExtensions
    Admin::PagesController.send :include, PageFactory::PagesControllerExtensions
  end
end
