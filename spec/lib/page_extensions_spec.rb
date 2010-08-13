require File.dirname(__FILE__) + '/../spec_helper'

class PageExtensionSpecPage < Page
  part 'alpha'
  part 'beta'
end

describe PageFactory::PageExtensions do

  it "should override Page.default_page_parts" do
    page = PageExtensionSpecPage.new_with_defaults(Radiant::Config)
    page.parts.map(&:name).should eql(%w(alpha beta))
  end

end