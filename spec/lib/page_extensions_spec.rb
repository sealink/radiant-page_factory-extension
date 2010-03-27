require File.dirname(__FILE__) + '/../spec_helper'

describe PageFactory::PageExtensions do
  class OverridingPageFactory < PageFactory
    part 'alpha'
    part 'beta'
  end

  it "should override Page.default_page_parts" do
    PageFactory.current_factory = OverridingPageFactory
    page = Page.new_with_defaults(Radiant::Config)
    page.parts.map(&:name).should eql(%w(alpha beta))
  end

  it "should constantize the page factory" do
    page = Page.new :page_factory => 'OverridingPageFactory'
    page.page_factory.should == OverridingPageFactory
  end
end