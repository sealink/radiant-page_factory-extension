class Admin::PageFactoriesController < ApplicationController
  def index
    @page = Page.find_by_id(params[:page])
    @factories = factories
    render :layout => false
  end

  private
    ##
    # If you need to limit what factories can be selected, alias chain this
    # method. The current user and @page (the page you're adding a child to)
    # are available here, so you can filter according to @page.class_name,
    # @page.page_factory, current_user roles, etc.
    #
    # @return [Array] an array of factory classes which you may then modify
    #
    # @example Don't let designers add Archive pages
    #   def factories_with_permissions
    #     if current_user.admin?
    #       factories_without_permissions
    #     else
    #       factories_without_permissions.reject { |f| f.page_class == 'ArchivePage' }
    #     end
    #   end
    #   alias_method_chain :factories, :permissions
    def factories
      [PageFactory::Base, *PageFactory::Base.descendants.sort { |a,b| a.name <=> b.name }]
    end
end
