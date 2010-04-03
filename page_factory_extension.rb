require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_factory"

  define_routes do |map|
    map.namespace :admin do |admin|
      admin.factory_link '/pages/factories', :controller => 'page_factories', :action => 'index'
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

    factory_paths = [Rails.root.to_s + '/lib']
    Radiant::Extension.descendants.inject factory_paths do |paths, ext|
      paths << ext.root + '/app/models'
      paths << ext.root + '/lib'
    end
    factory_paths.each do |path|
      Dir["#{path}/*_page_factory.rb"].each do |page_factory|
        if page_factory =~ %r{/([^/]+)\.rb}
          require_dependency page_factory
          ActiveSupport::Dependencies.explicitly_unloadable_constants << $1.camelize
        end
      end
    end
  end
end
