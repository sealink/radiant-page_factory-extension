require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  dataset :config, :users, :layouts

  class ControllerPageFactory < PageFactory::Base
    part 'alpha'
    part 'beta'
  end

  class ArchivePageFactory < PageFactory::Base
    layout 'UTF8'
    page_class 'ArchivePage'
  end

  before :each do
    login_as :admin
  end

  describe "#new" do
    it "should assign default parts when no factory is passed" do
      get :new
      assigns(:page).parts.map(&:name).should eql(%w(body extended))
    end

    it "should not set a page factory if none is given" do
      get :new
      assigns(:page).page_factory.should be_nil
    end

    it "should set the new page's factory" do
      get :new, :factory => 'ControllerPageFactory'
      assigns(:page).page_factory.should eql(ControllerPageFactory)
    end

    it "should set the current factory" do
      PageFactory.should_receive(:current_factory=).with('ControllerPageFactory').ordered
      PageFactory.should_receive(:current_factory=).with(nil).ordered
      
      get :new, :factory => 'ControllerPageFactory'
    end

    it "should assign parts to @page based on the current factory" do
      get :new, :factory => 'ControllerPageFactory'
      assigns(:page).parts.map(&:name).should eql(%w(body extended alpha beta))
    end

    it "should not choke on bad factory names" do
      get :new, :factory => 'BogusFactory'
      response.should be_success
    end

    it "should pass a layout" do
      get :new, :factory => 'ArchivePageFactory'
      assigns(:page).layout.should eql(layouts(:utf8))
    end

    it "should pass a page type" do
      get :new, :factory => 'ArchivePageFactory'
      assigns(:page).class_name.should eql('ArchivePage')
    end
  end
end