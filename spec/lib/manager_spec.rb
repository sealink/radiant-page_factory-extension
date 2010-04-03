require File.dirname(__FILE__) + '/../spec_helper'

describe PageFactory::Manager do
  dataset do
    create_record :page, :managed, :title => 'managed', :slug => 'managed', :breadcrumb => 'managed', :page_factory => 'ManagedPageFactory'
    create_record :page, :plain, :title => 'plain', :slug => 'plain', :breadcrumb => 'plain'
    create_record :page, :other, :title => 'other', :slug => 'other', :breadcrumb => 'other', :page_factory => 'OtherPageFactory'
    create_record :page_part, :existing, :name => 'existing'
    create_record :page_part, :old, :name => 'old'
    create_record :page_part, :new, :name => 'new'
  end

  class ManagedPageFactory < PageFactory::Base
    part 'existing'
    part 'new'
  end

  class OtherPageFactory < PageFactory::Base
    part 'new'
  end

  before do
    @managed, @plain, @other, @existing, @old, @new =
    pages(:managed), pages(:plain), pages(:other), page_parts(:existing), page_parts(:old), page_parts(:new)
  end

  describe ".prune_parts!" do
    it "should remove vestigial parts" do
      @managed.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts!
      @managed.reload.parts.should_not include(@old)
    end

    it "should leave listed parts alone" do
      @managed.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts!
      @managed.reload.parts.should include(@existing)
    end

    it "should leave Plain Old Pages alone" do
      @plain.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts!
      @plain.reload.parts.should include(@existing)
      @plain.reload.parts.should include(@old)
    end

    it "should operate on a single factory" do
      e, o = @existing.clone, @old.clone
      @managed.parts.concat [e, o]
      @other.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts! ManagedPageFactory
      @managed.parts.should_not include(o)
      @other.reload.parts.should include(@old)
    end

    it "should operate on Plain Old Pages" do
      PageFactory::Base.parts = [@old, @existing]
      @plain.parts << extra = PagePart.new(:name => 'extra')
      PageFactory::Manager.prune_parts! :PageFactory
      @plain.reload.parts.should_not include(extra)
    end
  end
  
  describe ".sync_parts!" do
    class AddPartClass < ActiveRecord::Migration
      def self.up
        add_column :page_parts, :part_class, :string
        PagePart.reset_column_information
      end

      def self.down
        remove_column :page_parts, :part_class
        PagePart.reset_column_information
      end
    end

    class SubPagePart < PagePart ; end

    before :all do
      ActiveRecord::Migration.verbose = false
      AddPartClass.up
      PagePart.class_eval do
        set_inheritance_column :part_class
      end
    end

    after :all do
      AddPartClass.down
      PagePart.class_eval do
        set_inheritance_column nil
      end
    end

    before :each do
      @part = SubPagePart.new(:name => 'new')
      @managed.parts = [@part]
    end

    it "should delete parts whose classes don't match" do
      PageFactory::Manager.sync_parts!
      @managed.reload.parts.should_not include(@new)
    end

    it "should replace parts whose classes don't match" do
      PageFactory::Manager.sync_parts!
      @managed.reload.parts.detect { |p| p.name == 'new'}.class.should == PagePart
    end

    it "should leave synced parts alone" do
      @managed.parts = [@new]
      PageFactory::Manager.sync_parts!
      @managed.reload.parts.should eql([@new])
    end

    it "should operate on a single factory" do
      c = @part.clone
      @other.parts = [c]
      PageFactory::Manager.sync_parts! :ManagedPageFactory
      @other.reload.parts.should include(c)
    end

    it "should operate on Plain Old Pages" do
      PageFactory::Base.parts = [@new]
      @plain.parts << SubPagePart.new(:name => 'new')
      PageFactory::Manager.sync_parts! :PageFactory
      @plain.reload.parts.detect { |p| p.name == 'new' }.class.should == PagePart
    end
  end

  describe ".update_parts" do
    it "should add missing parts" do
      @managed.parts.should be_empty
      PageFactory::Manager.update_parts
      @managed.parts.reload.map(&:name).should include('new')
    end

    it "should not duplicate existing parts" do
      @managed.parts.concat [@new, @existing]
      lambda { PageFactory::Manager.update_parts }.should_not change(@managed.parts, :size)
    end

    it "should not replace matching parts" do
      @managed.parts.concat [@new, @existing]
      PageFactory::Manager.update_parts
      @managed.reload
      @managed.parts.should include(@new)
      @managed.parts.should include(@existing)
    end

    it "should operate on a single factory" do
      @other.parts = [e = @existing.clone]
      PageFactory::Manager.update_parts :ManagedPageFactory
      @other.reload.parts.should == [e]
    end

    it "should operate on Plain Old Pages" do
      PageFactory::Base.parts = [@new]
      @plain.parts.should be_empty
      PageFactory::Manager.update_parts :PageFactory
      @plain.reload.parts.map(&:name).should include('new')
    end
  end
  
  describe ".sync_layouts!" do
    dataset do
      create_record :layout, :one, :name => 'Layout One'
      create_record :layout, :two, :name => 'Layout Two'
    end
    ManagedPageFactory.layout 'Layout One'
    OtherPageFactory.layout 'Layout One'

    before do
      @managed.layout = layouts(:two)
      @managed.save
    end

    it "should change page layout to match factory" do
      PageFactory::Manager.sync_layouts!
      @managed.reload.layout.should eql(layouts(:one))
    end

    it "should operate on a single factory" do
      @other.layout = layouts(:two)
      @other.save
      PageFactory::Manager.sync_layouts! :ManagedPageFactory
      @other.reload.layout.should eql(layouts(:two))
    end

    it "should operate on Plain Old Pages" do
      @plain.layout = layouts(:one)
      @plain.save
      PageFactory::Manager.sync_layouts! :PageFactory
      @plain.reload.layout.should be_nil
    end
  end

  describe ".sync_classes!" do
    class SubPage < Page ; end
    ManagedPageFactory.page_class 'SubPage'
    OtherPageFactory.page_class 'SubPage'

    it "should change page class to match factory" do
      PageFactory::Manager.sync_classes!
      pages(:managed).should be_kind_of(SubPage)
    end

    it "should operate on a single factory" do
      PageFactory::Manager.sync_classes! :ManagedPageFactory
      pages(:other).should be_kind_of(Page)
    end

    it "should operate on Plain Old Pages" do
      pages(:plain).update_attribute :class_name, 'SubPage'
      PageFactory::Manager.sync_classes! :PageFactory
      pages(:plain).class.should == Page
    end
  end
end