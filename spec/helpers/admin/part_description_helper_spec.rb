require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::PartDescriptionHelper do
  include Admin::PartDescriptionHelper

  class DescriptionHelperSpecPage < Page
    part 'normal', :description => 'desc'
  end

  class DescriptionPart < PagePart ; end

  before do
    @page = DescriptionHelperSpecPage.new
    @part = PagePart.new :name => 'normal'
  end

  it "should get description from Page.parts array" do
    description_for(@part).should eql('desc')
  end

  it "should return nothing if page is unset" do
    # as is the case when adding parts
    @page = nil
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