require File.dirname(__FILE__) + '/../spec_helper'

describe PageFactory::Manager do
  dataset do
    create_record :page, :managed, :title => 'managed', :slug => 'managed', :breadcrumb => 'managed', :page_factory => 'ManagedPageFactory'
    create_record :page, :plain, :title => 'plain', :slug => 'plain', :breadcrumb => 'plain'
    create_record :page_part, :existing, :name => 'existing'
    create_record :page_part, :old, :name => 'old'
    create_record :page_part, :new, :name => 'new'
  end

  class ManagedPageFactory < PageFactory
    part 'existing'
    part 'new'
  end

  before do
    @managed, @plain, @existing, @old, @new =
    pages(:managed), pages(:plain), page_parts(:existing), page_parts(:old), page_parts(:new)
  end

  describe "#prune!" do
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

    it "should operate on a single factory"
  end

  describe "#update!" do
    it "should add missing parts"
    it "should not override matching parts"
    it "should override parts whose classes don't match"
    it "should operate on a single factory"
  end
  
end