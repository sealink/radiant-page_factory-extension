ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.factory_link '/pages/factories', :controller => 'page_factories', :action => 'index'
  end
end