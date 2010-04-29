module PageFactory
  module PageExtensions
    def self.included(base)
      base.instance_eval do
        def default_page_parts(config=Radiant::Config)
          PageFactory.current_factory.parts
        end
        private_class_method :default_page_parts
      end
      base.class_eval do
        ##
        # The PageFactory that was used to create this page. Note that Plain
        #   Old Pages do not have an assigned factory.
        #
        # @return [PageFactory, nil] This Page's initial PageFactory
        def page_factory
          (factory = read_attribute(:page_factory)).blank? ? nil : factory.constantize
        rescue NameError => e # @page.page_factory is not a constant. class was removed?
          logger.warn "Couldn't find page factory: #{e.message}"
          nil
        end
      end
    end
  end
end