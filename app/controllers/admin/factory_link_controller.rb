class Admin::FactoryLinkController < ApplicationController
  def new
    @page = Page.find_by_id(params[:page])
    render :layout => false
  end
end
