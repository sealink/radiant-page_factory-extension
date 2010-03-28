require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PartDescriptionHelper do
  include Admin::PartDescriptionHelper

  class DescriptionPageFactory < PageFactory
    part 'normal', :description => 'sub'
  end

  class DescriptionPart < PagePart ; end

  before do
    @page = Page.new :page_factory => 'DescriptionPageFactory'
    @part = PagePart.new :name => 'normal'
  end

  it "should get description from page factory" do
    description_for(@part).should eql('sub')
  end

  it "should return nothing if page is unset" do
    # as is the case when adding parts
    @page = nil
    description_for(@part).should be_blank
  end

  it "should return nothing if factory is unset" do
    @page.page_factory = nil
    description_for(@part).should be_blank
  end

  it "should not describe a different part class" do
    part = DescriptionPart.new :name => 'normal'
    description_for(part).should be_blank
  end

  it "should recover from a missing factory" do
    # descriptions are the only place we ever refer to a page's factory while
    # the app is running. since it's possible that a factory was removed or
    # renamed, it would be nice to not blow up on it.
    @page.page_factory = 'BogusPageFactory'
    description_for(@part).should be_blank
  end

  private

    def logger
      double('logger').as_null_object
    end
end