require File.dirname(__FILE__) + '/../spec_helper'

describe PageFactory::Manager do
  dataset do
    create_record :page, :managed, :title => 'managed', :slug => 'managed', :breadcrumb => 'managed', :class_name => 'ManagedPage'
    create_record :page, :plain, :title => 'plain', :slug => 'plain', :breadcrumb => 'plain'
    create_record :page, :other, :title => 'other', :slug => 'other', :breadcrumb => 'other', :class_name => 'OtherPage'
    create_record :page_part, :existing, :name => 'existing'
    create_record :page_part, :old, :name => 'old'
    create_record :page_part, :new, :name => 'new'
  end

  class Page < ActiveRecord::Base
    part 'existing'
    part 'new'
  end

  class ManagedPage < Page
    part 'new'
  end

  class OtherPage < Page
    part 'new'
  end

  before do
    @managed, @plain, @other, @existing, @old, @new =
    pages(:managed), pages(:plain), pages(:other), page_parts(:existing), page_parts(:old), page_parts(:new)
  end

  describe ".prune_parts!" do
    it "should remove vestigial parts" do
      @plain.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts!
      @plain.reload.parts.should_not include(@old)
    end

    it "should leave listed parts alone" do
      @plain.parts.concat [@existing, @old]
      PageFactory::Manager.prune_parts!
      @plain.reload.parts.should include(@existing)
    end

    it "should operate on a single subclass" do
      @plain.parts.concat [old = @old.clone]
      @managed.parts.concat [@old]
      PageFactory::Manager.prune_parts! ManagedPage
      @plain.parts.should include(old)
      @managed.reload.parts.should_not include(@old)
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
      @plain.parts = [@part]
    end

    it "should delete parts whose classes don't match" do
      PageFactory::Manager.sync_parts!
      @plain.reload.parts.should_not include(@new)
    end

    it "should replace parts whose classes don't match" do
      PageFactory::Manager.sync_parts!
      @plain.reload.parts.detect { |p| p.name == 'new'}.class.should == PagePart
    end

    it "should leave synced parts alone" do
      @plain.parts = [@new]
      PageFactory::Manager.sync_parts!
      @plain.reload.parts.should eql([@new])
    end

    it "should operate on a single subclass" do
      c = @part.clone
      @plain.parts = [c]
      PageFactory::Manager.sync_parts! :ManagedPage
      @plain.reload.parts.should include(c)
    end
  end

  describe ".update_parts" do
    it "should add missing parts" do
      @plain.parts.should be_empty
      PageFactory::Manager.update_parts
      @plain.parts.reload.map(&:name).should include('new')
    end

    it "should not duplicate existing parts" do
      @plain.parts.concat [@new, @existing]
      lambda { PageFactory::Manager.update_parts }.should_not change(@plain.parts, :size)
    end

    it "should not replace matching parts" do
      @plain.parts.concat [@new, @existing]
      PageFactory::Manager.update_parts
      @plain.reload
      @plain.parts.should include(@new)
      @plain.parts.should include(@existing)
    end

    it "should operate on a single subclasses" do
      @plain.parts = [e = @existing.clone]
      PageFactory::Manager.update_parts :ManagedPage
      @plain.reload.parts.should == [e]
    end
  end
  
  describe ".sync_layouts!" do
    dataset do
      create_record :layout, :one, :name => 'Layout One'
      create_record :layout, :two, :name => 'Layout Two'
    end
    Page.layout 'Layout One'
    ManagedPage.layout 'Layout One'
    OtherPage.layout 'Layout One'

    before do
      @plain.layout = layouts(:two)
      @plain.save
    end

    it "should change page layout to match factory" do
      PageFactory::Manager.sync_layouts!
      @plain.reload.layout.should eql(layouts(:one))
    end

    it "should operate on a single factory" do
      PageFactory::Manager.sync_layouts! :ManagedPage
      @plain.reload.layout.should eql(layouts(:two))
    end
  end

end
