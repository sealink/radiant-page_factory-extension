require File.dirname(__FILE__) + '/../spec_helper'

class PageExtensionSpecPageOne < Page
end

class PageExtensionSpecPageTwo < Page
  part 'extra'
end

describe PageFactory::PageExtensions do
  before do
    @config = {'defaults.page.parts' => 'body, extended'}
  end

  it "should inherit page.default.parts" do
    page = PageExtensionSpecPageOne.new_with_defaults(@config)
    page.parts.map(&:name).should eql(%w(body extended))
  end

  it "should extend Page.default_page_parts" do
    page = PageExtensionSpecPageTwo.new_with_defaults(@config)
    page.parts.map(&:name).should include('extra')
  end

end