require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_factory"

  define_routes do |map|
    map.namespace :admin do |admin|
      admin.factory_link '/pages/factory_link', :controller => 'factory_link', :action => 'new'
    end
  end
  
  def activate
    Page.send :include, PageFactory::PageExtensions
    Admin::PagesController.send :include, PageFactory::PagesControllerExtensions

    ([RADIANT_ROOT] + Radiant::Extension.descendants.map(&:root)).each do |path|
      Dir["#{path}/app/models/*_page_factory.rb"].each do |page_part|
         $1.camelize.constantize if page_part =~ %r{/([^/]+)\.rb}
      end
    end
  end
end
