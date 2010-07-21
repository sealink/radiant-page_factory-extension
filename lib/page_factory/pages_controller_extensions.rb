module PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.class_eval do
        around_filter :set_page_factory, :only => :new
        before_filter { |c| c.include_stylesheet 'admin/dropdown' }
        before_filter { |c| c.include_javascript 'admin/dropdown' }
        before_filter { |c| c.include_javascript 'admin/pagefactory' }
        responses.new.default do
          set_page_defaults
        end
      end
    end

    def set_page_factory
      begin
        PageFactory.current_factory = params[:factory]
      rescue NameError => e # bad factory name passed
        logger.error "Tried to create page with invalid factory: #{e.message}"
      ensure
        yield
        PageFactory.current_factory = nil
      end
    end

    def set_page_defaults
      model.class_name = PageFactory.current_factory.page_class
      model.layout = Layout.find_by_name(PageFactory.current_factory.layout)
      model.page_factory = PageFactory.current_factory.name unless PageFactory::Base == PageFactory.current_factory
    end
  end
end