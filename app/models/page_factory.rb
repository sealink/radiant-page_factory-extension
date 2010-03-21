class PageFactory

  class << self
    attr_accessor :parts, :current_factory

    def inherited(subclass)
      subclass.parts = @parts.dup
    end

    def part(name, attrs={})
      @parts.delete_if { |p| name == p.name }
      @parts << PagePart.new(attrs.merge(:name => name))
    end

    def current_factory
      @current_factory || PageFactory
    end

    def current_factory=(factory)
      factory = factory.constantize if factory.is_a?(String)
      if factory.nil? or factory <= PageFactory
        @current_factory = factory
      end
    end

    private
      def default_page_parts(config = Radiant::Config)
        default_parts = config['defaults.page.parts'].to_s.strip.split(/\s*,\s*/)
        default_parts.map do |name|
          PagePart.new(:name => name, :filter_id => config['defaults.page.filter'])
        end
      end
  end
  
  @parts = default_page_parts
end
