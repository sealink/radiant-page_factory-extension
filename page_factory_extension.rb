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
    PagePart.send :include, PageFactory::PagePartExtensions
    Admin::PagesController.send :include, PageFactory::PagesControllerExtensions
    Admin::PagesController.helper 'admin/part_description'
    Admin::PagePartsController.helper 'admin/part_description'
    admin.pages.new.add :form, 'page_factory_field'
    admin.pages.edit.add :part_controls, 'admin/page_parts/part_description'

    ([RADIANT_ROOT] + Radiant::Extension.descendants.map(&:root)).each do |path|
      Dir["#{path}/app/models/*_page_factory.rb"].each do |page_factory|
        if page_factory =~ %r{/([^/]+)\.rb}
          ActiveSupport::Dependencies.explicitly_unloadable_constants << $1.camelize
          $1.camelize.constantize
        end
      end
    end
  end
end
