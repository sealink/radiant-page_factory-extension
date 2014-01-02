module PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.class_eval do
        def model_name
          model_class.base_class.name
        end

        def model_class
          @model_class ||= begin
            if params[:page_class] && (klass = params.delete(:page_class).constantize) <= Page
              klass
            else
              super
            end
          rescue NameError => e
            logger.warn "Wrong Page class given in Pages#new: #{e.message}"
            super
          end
        end
        # alias_method_chain :model_class, :factory
        # alias_method_chain :assign_page_attributes, :factory
      end
    end

    def assign_page_attributes
      super
      model.layout = Layout.find_by_name(model_class.layout)
    end
  end
end