# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class PageFactoryExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/page_factory"
  
  # extension_config do |config|
  #   config.gem 'some-awesome-gem
  #   config.after_initialize do
  #     run_something
  #   end
  # end

  # define_routes do |map|
  #   map.namespace :admin, :member => { :remove => :get } do |admin|
  #     admin.resources :page_factory
  #   end
  # end
  
  def activate
    # tab 'Content' do
    #   add_item "Page Factory", "/admin/page_factory", :after => "Pages"
    # end
  end
end
