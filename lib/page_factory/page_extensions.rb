class PageFactory
  module PageExtensions
    def self.included(base)
      base.instance_eval do
        def default_page_parts(config=Radiant::Config)
          PageFactory.current_factory.parts
        end
        private_class_method :default_page_parts
      end
    end
  end
end