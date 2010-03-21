require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::FactoryLinkHelper do
  include Admin::FactoryLinkHelper

  it "should give a link for a new page" do
    link_for(nil).should eql(new_admin_page_path)
  end

  it "should give a link for an existing page" do
    link_for(1).should eql(new_admin_page_child_path(1))
  end
end