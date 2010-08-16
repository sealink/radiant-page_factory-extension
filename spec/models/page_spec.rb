require File.dirname(__FILE__) + '/../spec_helper'

class PageSpecPage < Page
  part 'alpha'
  part 'beta'
  part 'gamma'

  field 'uno'
  field 'dos'
  field 'tres'
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

  describe ".remove_part" do
    it "should remove a single part" do
      PageSpecPage.remove_part :alpha
      PageSpecPage.parts.map(&:name).should_not include('alpha')
    end

    it "should remove a list of parts" do
      PageSpecPage.remove_part :beta, :gamma
      PageSpecPage.parts.map(&:name).should_not include('beta')
      PageSpecPage.parts.map(&:name).should_not include('gamma')
    end
  end

  describe ".field" do
    it "should add a field" do
      PageSpecPage.field 'Author'
      PageSpecPage.fields.find { |f| f.name == 'Author' }.should be_a(PageField)
    end

    it "should add a field with attributes" do
      PageSpecPage.field 'Author', :content => 'Vaclav Speezl-Ganglia'
      PageSpecPage.fields.find { |f| f.name == 'Author' }.content.should == 'Vaclav Speezl-Ganglia'
    end

    it "should override a part" do
      PageSpecPage.field 'Author', :content => 'Vaclav Speezl-Ganglia'
      PageSpecPage.field 'Author', :content => 'Boutros Boutros-Ghali'
      PageSpecPage.fields.find { |f| f.name == 'Author' }.content.should == 'Boutros Boutros-Ghali'
    end
  end

  describe ".remove_field" do
    it "should remove a single field" do
      PageSpecPage.remove_field :uno
      PageSpecPage.fields.map(&:name).should_not include('uno')
    end

    it "should remove a list of fields" do
      PageSpecPage.remove_field :dos, :tres
      PageSpecPage.fields.map(&:name).should_not include('dos')
      PageSpecPage.fields.map(&:name).should_not include('tres')
    end
  end
end