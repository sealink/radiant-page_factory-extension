module PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.class_eval do
        def model_name
          model_class.base_class.name
        end

        def model_class_with_factory
          @model_class ||= begin
            if params[:page_class] && (klass = params.delete(:page_class).constantize) <= Page
              klass
            else
              model_class_without_factory
            end
          rescue NameError => e
            logger.warn "Wrong Page class given in Pages#new: #{e.message}"
            model_class_without_factory
          end
        end
        alias_method_chain :model_class, :factory
        alias_method_chain :assign_page_attributes, :factory
      end
    end

    def assign_page_attributes_with_factory
      assign_page_attributes_without_factory
      model.layout = Layout.find_by_name(model_class.layout)
    end
  end
end