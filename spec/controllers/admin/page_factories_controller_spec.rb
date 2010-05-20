require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageFactoriesController do
  dataset :users, :pages

  class ParamPageFactory < PageFactory::Base
  end

  before do
    login_as :admin
  end

  describe "index" do
    it "should expose page instance" do
      get :index, :page => page_id(:home)
      assigns(:page).should eql(pages(:home))
    end

    it "should expose factory list" do
      get :index, :page => page_id(:home)
      assigns(:factories).should include(PageFactory::Base)
    end

  end

  describe ".factory_link" do
    before :all do
      Admin::PageFactoriesController.send :public, :factory_link
    end

    it "should give a link for a new page" do
      controller.instance_variable_set :@page, nil
      controller.factory_link.should eql(new_admin_page_path)
    end

    it "should give a link for an existing page" do
      controller.instance_variable_set :@page, pages(:home)
      controller.factory_link.should eql(new_admin_page_child_path(pages(:home)))
    end

    it "should create a link with a page_factory param" do
      controller.instance_variable_set :@page, pages(:home)
      controller.factory_link(ParamPageFactory).should eql(new_admin_page_child_path(pages(:home), :factory => 'ParamPageFactory'))
    end
  end

end