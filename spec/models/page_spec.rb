require File.dirname(__FILE__) + '/../spec_helper'

describe Page do
  class ConstantizedPageFactory < PageFactory::Base
  end

  before do
    @page = Page.new
  end

  describe ".page_factory" do
    it "should constantize the factory" do
      @page.page_factory = 'ConstantizedPageFactory'
      @page.page_factory.should eql(ConstantizedPageFactory)
    end

    it "should return nil if no factory is set" do
      @page.page_factory = nil
      @page.page_factory.should be_nil
    end

    it "should not blow up if the factory has gone missing" do
      @page.page_factory = 'BogusPageFactory'
      @page.page_factory.should be_nil
    end
  end
end