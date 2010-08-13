require File.dirname(__FILE__) + '/../spec_helper'

class PageSpecPage < Page
end

describe Page do
  describe '.part' do
    it "should add a part to page_parts" do
      PageSpecPage.part 'Sidebar'
      PageSpecPage.parts.find { |p| p.name == 'Sidebar'}.should be_a(PagePart)
    end

    it "should add a part with attributes" do
      PageSpecPage.part 'Filtered', :filter_id => 'markdown'
      PageSpecPage.parts.find { |p| p.name == 'Filtered'}.filter_id.should eql('markdown')
    end

    it "should override a part" do
      PageSpecPage.part 'Override', :filter_id => 'old id'
      PageSpecPage.part 'Override', :filter_id => 'new id'
      PageSpecPage.parts.find { |p| p.name == 'Override'}.filter_id.should eql('new id')
    end
  end
end