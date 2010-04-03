module Admin::FactoryLinkHelper
  def factory_link_for(page)
    page.nil? ? new_admin_page_path : new_admin_page_child_path(page)
  end

  def factory_options
    factories.map do |f|
      [f.template_name,
       f < PageFactory ? f : nil]
    end
  end

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
    [PageFactory, *PageFactory.descendants.sort { |a,b| a.name <=> b.name }]
  end

end
