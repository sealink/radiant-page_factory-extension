module PageFactory
  module PageExtensions

    def self.included(base)
      base.instance_eval do
        class_inheritable_array_writer :parts, :instance_writer => false
        self.parts = default_page_parts

        def layout(name = nil)
          @layout = name || @layout
        end

        def parts
          read_inheritable_attribute :parts
        end

        def default_page_parts_with_factory(config = Radiant::Config)
          self.parts
        end

        def part(name, attrs={})
          remove name.to_s
          self.parts << PagePart.new(attrs.merge(:name => name.to_s))
        end

        def remove(*names)
          names = names.map(&:to_s).map(&:downcase)
          self.parts.delete_if { |p| names.include? p.name.to_s.downcase }
        end
      end

      class << base
        alias_method_chain :default_page_parts, :factory
      end
    end

  end
end