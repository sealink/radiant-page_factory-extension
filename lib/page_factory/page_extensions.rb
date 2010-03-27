class PageFactory
  module PageExtensions
    def self.included(base)
      base.instance_eval do
        def default_page_parts(config=Radiant::Config)
          PageFactory.current_factory.parts
        end
        private_class_method :default_page_parts
      end
      base.class_eval do
        def page_factory
          read_attribute(:page_factory).try :constantize
        end
      end
    end
  end
end