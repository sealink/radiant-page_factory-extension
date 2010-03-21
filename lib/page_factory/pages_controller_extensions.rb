class PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.around_filter :set_page_factory, :only => :new
    end

    def set_page_factory
      PageFactory.current_factory = params[:page_factory]
      yield
    ensure
      PageFactory.current_factory = nil
    end
  end
end