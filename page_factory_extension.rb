require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version YAML::load_file(File.join(File.dirname(__FILE__), 'VERSION'))
  description "A small DSL for intelligently defining content types."
  url "http://github.com/joshfrench/radiant-page_factory-extension"

  def activate
    Page.send :include, PageFactory::PageExtensions
    PagePart.send :include, PageFactory::PagePartExtensions
    Admin::PagesController.send :include, PageFactory::PagesControllerExtensions
    Admin::PagesController.helper 'admin/part_description'
    Admin::PagePartsController.helper 'admin/part_description'
    admin.pages.edit.add :part_controls, 'admin/page_parts/part_description'
    ActiveSupport::Dependencies.load_paths << File.join(Rails.root, 'lib')
    ActiveSupport::Dependencies.load_paths << File.join(Rails.root, %w(app models))
  end
end
