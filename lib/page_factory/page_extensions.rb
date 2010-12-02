module PageFactory
  module PageExtensions

    def self.included(base)
      base.instance_eval do
        class_inheritable_array_writer :parts, :fields, :instance_writer => false
        self.parts = default_page_parts
        self.fields = default_page_fields

        def layout(name = nil)
          @layout = name || @layout
        end

        %w(part field).each do |attr|
          instance_eval %{
            def #{attr}s                                                      # def parts
              read_inheritable_attribute :#{attr}s                            #   read_inheritable_attribute :parts
            end                                                               # end

            def default_page_#{attr}s_with_factory(config = Radiant::Config)  # def default_page_parts_with_factory
              self.#{attr}s                                                   #   self.parts
            end                                                               # end

            def #{attr}(name, attrs={})                                       # def part(name, attrs={})
              remove_#{attr} name.to_s                                        #   remove_part name.to_s
              self.#{attr}s <<                                                #   self.parts <<
                Page#{attr.capitalize}.new(attrs.merge(:name => name.to_s))   #     PagePart.new(attrs.merge(:name => name.to_s))
            end                                                               # end

            def remove_#{attr}(*names)                                        # def remove_part(*names)
              names = names.map(&:to_s).map(&:downcase)                       #   names = names.map(&:to_s).map(&:downcase)
              self.#{attr}s.delete_if {                                       #   self.parts.delete_if {
                |a| names.include? a.name.to_s.downcase                       #     |a| names.include? a.name.to_s.downcase
              }                                                               #   }
            end                                                               # end
          }, __FILE__, __LINE__
        end

        def remove(*names)
          ActiveSupport::Deprecation.warn("Page.remove is deprecated, please use Page.remove_part instead", caller)
          remove_part(*names)
        end

        def load_subclasses_with_factory
          load_subclasses_without_factory
          %w(app/models lib).each do |path|
            Dir["#{Rails.root}/#{path}/*_page.rb"].each do |page|
              $1.camelize.constantize if page =~ %r{/([^/]+)\.rb}
            end
          end
        end
      end

      class << base
        alias_method_chain :default_page_parts, :factory
        alias_method_chain :default_page_fields, :factory
        alias_method_chain :load_subclasses, :factory
        alias_method :remove_parts, :remove_part
        alias_method :remove_fields, :remove_field
      end
    end

  end
end
