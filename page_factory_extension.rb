# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_factory"
  
  def activate
    Page.send :include, PageFactory::PageExtensions
  end
end
