require File.dirname(__FILE__) + '/../spec_helper'

class PageExtensionSpecPageOne < Page
end

class PageExtensionSpecPageTwo < Page
  part 'extra'
  field 'additional'
end

describe PageFactory::PageExtensions do
  before do
    @config = {'defaults.page.parts' => 'body, extended', 'default.page.fields' => 'Description, Keywords'}
  end

  it "should inherit page.default.parts" do
    page = PageExtensionSpecPageOne.new_with_defaults(@config)
    page.parts.map(&:name).should eql(%w(body extended))
  end

  it "should extend Page.default_page_parts" do
    page = PageExtensionSpecPageTwo.new_with_defaults(@config)
    page.parts.map(&:name).should include('extra')
  end

  it "should inherit page.default.fields" do
    page = PageExtensionSpecPageOne.new_with_defaults(@config)
    page.fields.map(&:name).should include('keywords')
    page.fields.map(&:name).should include('description')
  end

  it "should extend page.default.fields" do
    page = PageExtensionSpecPageTwo.new_with_defaults(@config)
    page.fields.map(&:name).should include('additional')
  end

end