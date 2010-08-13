module PageFactory
  module PagesControllerExtensions
    def self.included(base)
      base.class_eval do
        responses.new.default do
           initialize_layout
         end

        def model_name
          model_class.base_class.name
        end

        def model_class_with_factory
          @model_class ||= begin
            if params[:page_class] && (klass = params[:page_class].constantize) <= Page
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
      end
    end

    def initialize_layout
      model.layout = Layout.find_by_name(model_class.layout)
    end
  end
end