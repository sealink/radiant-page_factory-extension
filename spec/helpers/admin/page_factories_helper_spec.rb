require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PageFactoriesHelper do
  dataset :pages
  include Admin::PageFactoriesHelper

  class ParamPageFactory < PageFactory::Base
  end

  it "should give a link for a new page" do
    @page = nil
    factory_link.should eql(new_admin_page_path)
  end

  it "should give a link for an existing page" do
    @page = pages(:home)
    factory_link.should eql(new_admin_page_child_path(pages(:home)))
  end

  it "should create a link with a page_factory param" do
    @page = pages(:home)
    factory_link(ParamPageFactory).should eql(new_admin_page_child_path(pages(:home), :factory => 'ParamPageFactory'))
  end
end