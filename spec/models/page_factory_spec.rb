require File.dirname(__FILE__) + '/../spec_helper'

describe PageFactory do
  
  class SubPageFactory < PageFactory::Base
  end

  it "should have the default page parts" do
    PageFactory::Base.parts.should == Page.new_with_defaults(Radiant::Config).parts
  end

  it "should inherit page_parts" do
    SubPageFactory.parts.should == PageFactory::Base.parts
  end

  it "should inherit page_class and layout" do
    SubPageFactory.layout = 'LayoutName'
    SubPageFactory.page_class = 'ClassName'
    class ThirdPageFactory < SubPageFactory ; end

    ThirdPageFactory.layout.should eql('LayoutName')
    ThirdPageFactory.page_class.should eql('ClassName')
  end

  describe '.part' do
    it "should add a part to page_parts" do
      SubPageFactory.part 'Sidebar'
      SubPageFactory.parts.find { |p| p.name == 'Sidebar'}.should be_a(PagePart)
    end

    it "should add a part with attributes" do
      SubPageFactory.part 'Filtered', :filter_id => 'markdown'
      SubPageFactory.parts.find { |p| p.name == 'Filtered'}.filter_id.should eql('markdown')
    end

    it "should override a part" do
      SubPageFactory.part 'Override', :filter_id => 'old id'
      SubPageFactory.part 'Override', :filter_id => 'new id'
      SubPageFactory.parts.find { |p| p.name == 'Override'}.filter_id.should eql('new id')
    end
  end

  describe '.remove' do
    class FullPageFactory < PageFactory::Base
      part 'one'
      part 'two'
    end

    class EmptyPageFactory < FullPageFactory
    end

    it "should remove a part" do
      EmptyPageFactory.remove 'one'
      EmptyPageFactory.parts.map(&:name).should_not include('one')
    end

    it "should not be case sensitive" do
      EmptyPageFactory.remove 'TWO'
      EmptyPageFactory.parts.map(&:name).should_not include('two')
    end

    it "should remove any number of parts" do
      FullPageFactory.remove 'one', 'two'
      FullPageFactory.parts.should be_empty
    end
  end

  describe ".current_factory" do
    class DefinedPageFactory < PageFactory::Base
      part 'alpha'
      part 'beta'
    end

    it "should return parts from the currently specified factory" do
      PageFactory.current_factory = DefinedPageFactory
      PageFactory.current_factory.parts.should eql(DefinedPageFactory.parts)
    end

    it "should not override other factories" do
      PageFactory.current_factory = DefinedPageFactory
      SubPageFactory.parts.should_not eql(DefinedPageFactory.parts)
    end

    it "should return base class by default" do
      PageFactory.current_factory = nil
      PageFactory.current_factory.parts.should eql(PageFactory::Base.parts)
    end

    it "should should accept a string" do
      PageFactory.current_factory = 'DefinedPageFactory'
      PageFactory.current_factory.should eql(DefinedPageFactory)
    end
  end

end
