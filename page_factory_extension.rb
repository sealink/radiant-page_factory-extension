require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "0.1"
  description "A small DSL for intelligently defining content types."
  url "http://github.com/jfrench/radiant-page_factory-extension"

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
    ActiveSupport::Dependencies.load_paths << File.join(Rails.root, 'lib')
  end
end
