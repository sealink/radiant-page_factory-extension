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

  class ManagedPageFactory < PageFactory
    part 'existing'
    part 'new'
  end

  class OtherPageFactory < PageFactory
    part 'new'
  end

  before do
    @managed, @plain, @other, @existing, @old, @new =
    pages(:managed), pages(:plain), pages(:other), page_parts(:existing), page_parts(:old), page_parts(:new)
  end

  describe ".prune!" do
    it "should remove vestigial parts" do
      @managed.parts.concat [@existing, @old]
      PageFactory::Manager.prune!
      @managed.reload.parts.should_not include(@old)
    end

    it "should leave listed parts alone" do
      @managed.parts.concat [@existing, @old]
      PageFactory::Manager.prune!
      @managed.reload.parts.should include(@existing)
    end

    it "should leave Plain Old Pages alone" do
      @plain.parts.concat [@existing, @old]
      PageFactory::Manager.prune!
      @plain.reload.parts.should include(@existing)
      @plain.reload.parts.should include(@old)
    end

    it "should operate on a single factory" do
      e, o = @existing.clone, @old.clone
      @managed.parts.concat [e, o]
      @other.parts.concat [@existing, @old]
      PageFactory::Manager.prune! ManagedPageFactory
      @managed.parts.should_not include(o)
      @other.reload.parts.should include(@old)
    end

    it "should operate on Plain Old Pages"
  end
  
  describe ".sync!" do
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
      PageFactory::Manager.sync!
      @managed.reload.parts.should_not include(@new)
    end

    it "should replace parts whose classes don't match" do
      PageFactory::Manager.sync!
      @managed.reload.parts.detect { |p| p.name == 'new'}.class.should == PagePart
    end

    it "should leave synced parts alone" do
      @managed.parts = [@new]
      PageFactory::Manager.sync!
      @managed.reload.parts.should eql([@new])
    end

    it "should operate on a single factory" do
      c = @part.clone
      @other.parts = [c]
      PageFactory::Manager.sync! :ManagedPageFactory
      @other.reload.parts.should include(c)
    end

    it "should operate on Plain Old Pages"
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

    it "should operate on Plain Old Pages"
  end
  
  describe "#update_layouts!" do
    dataset do
      create_record :layout, :one, :name => 'Layout One'
      create_record :layout, :two, :name => 'Layout Two'
    end

    before do
      ManagedPageFactory.layout 'Layout One'
      OtherPageFactory.layout 'Layout One'
      @managed.layout = layouts(:two)
      @managed.save
    end

    it "should change page layout to match factory" do
      PageFactory::Manager.update_layouts!
      @managed.reload.layout.should eql(layouts(:one))
    end

    it "should operate on a single factory" do
      @other.layout = layouts(:two)
      @other.save
      PageFactory::Manager.update_layouts! :ManagedPageFactory
      @other.reload.layout.should eql(layouts(:two))
    end

    it "should operate on Plain Old Pages"
  end

  describe "#update_classes!" do
    it "should change page class to match factory"
    it "should operate on a single factory"
    it "should operate on Plain Old Pages"
  end
end