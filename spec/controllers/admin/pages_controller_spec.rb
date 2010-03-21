require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PagesController do
  dataset :users

  class ControllerPageFactory < PageFactory
    part 'alpha'
    part 'beta'
  end

  before do
    login_as :admin
  end

  describe "#new" do
    it "should set the page factory" do
      PageFactory.should_receive(:current_factory=).with('ControllerPageFactory').ordered
      PageFactory.should_receive(:current_factory=).with(nil).ordered
      
      get :new, :page_factory => 'ControllerPageFactory'
    end

    it "should assign parts to @page based on the current factory" do
      get :new, :page_factory => 'ControllerPageFactory'
      assigns(:page).parts.map(&:name).should eql(%w(alpha beta))
    end
  end
end