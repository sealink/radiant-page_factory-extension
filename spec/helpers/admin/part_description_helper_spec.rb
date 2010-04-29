require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PartDescriptionHelper do
  include Admin::PartDescriptionHelper

  class DescriptionPageFactory < PageFactory::Base
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

  private

    def logger
      double('logger').as_null_object
    end
end