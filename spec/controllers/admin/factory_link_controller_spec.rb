require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::FactoryLinkController do
  dataset :users, :pages

  before do
    login_as :admin
  end

  describe "new" do
    it "should expose page instance" do
      get :new, :page => page_id(:home)
      assigns(:page).should eql(pages(:home))
    end

    it "should expose factory list" do
      get :new, :page => page_id(:home)
      assigns(:factories).should include(PageFactory)
    end
  end

end