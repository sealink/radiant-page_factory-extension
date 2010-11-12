require File.dirname(__FILE__) + '/../spec_helper'


describe PageFactory::PageExtensions do
  before :all do
    Page.part :part
    Page.field :field

    class PageExtensionSpecPage < Page
      part 'extra'
      field 'additional'
    end

    @page = PageExtensionSpecPage.new_with_defaults
  end

  after :all do
    Page.remove_part :part
    Page.remove_field :field
  end

  it "should inherit page.default.parts" do
    @page.parts.map(&:name).should include('part')
  end

  it "should extend Page.default_page_parts" do
    @page.parts.map(&:name).should include('extra')
  end

  it "should inherit page.default.fields" do
    @page.fields.map(&:name).should include('field')
  end

  it "should extend page.default.fields" do
    @page.fields.map(&:name).should include('additional')
  end

end
