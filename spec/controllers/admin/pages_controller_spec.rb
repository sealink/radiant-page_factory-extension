require File.dirname(__FILE__) + '/../../spec_helper'

class ControllerSpecPage < Page
  layout 'UTF8'
  part 'new_part'
  field 'field'
end

describe Admin::PagesController do
  dataset :config, :users, :layouts

  before :each do
    login_as :admin
  end

  describe "#new" do
    context 'without a class param' do
      before do
        Page.part :original
        get :new
      end

      it "should assign default parts when no class is passed" do
        assigns(:page).parts.map(&:name).should == Page.new_with_defaults.parts.map(&:name)
      end

      it "should not set a page class if none is given" do
        assigns(:page).class_name.should be_nil
      end
    end

    context 'with a class param' do
      before do
        get :new, :page_class => 'ControllerSpecPage'
      end

      it "should set the new page's class" do
        assigns(:page).class_name.should eql('ControllerSpecPage')
      end

      it "should assign parts to @page based on the class" do
        assigns(:page).parts.map(&:name).should include('new_part')
      end

      it "should assign fields" do
        assigns(:page).fields.map(&:name).should include('field')
      end

      it "should set a layout" do
        assigns(:page).layout.should eql(layouts(:utf8))
      end

      it "should not choke on bad class names" do
        get :new, :page_class => 'BogusPage'
        response.should be_success
      end
    end

  end
end
