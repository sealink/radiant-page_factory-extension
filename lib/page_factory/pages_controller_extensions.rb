class PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.class_eval do
        around_filter :set_page_factory, :only => :new
        alias_method_chain :new, :defaults
      end
    end

    def set_page_factory
      begin
        PageFactory.current_factory = params[:page_factory]
      rescue NameError => e # bad factory name passed
        logger.error "Tried to create page with invalid factory: #{e.message}"
      ensure
        yield
        PageFactory.current_factory = nil
      end
    end

    def new_with_defaults
      new_without_defaults
      model.class_name = PageFactory.current_factory.page_class
      model.layout = Layout.find_by_name(PageFactory.current_factory.layout)
    end
  end
end