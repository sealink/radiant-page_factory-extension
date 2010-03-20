class PageFactory

  class << self
    attr_accessor :__page_parts, :current_factory

    def parts
      (@current_factory || self).__page_parts
    end

    def inherited(subclass)
      subclass.__page_parts = @__page_parts.dup
    end

    def part(name, attrs={})
      @__page_parts.delete_if { |p| name == p.name }
      @__page_parts << PagePart.new(attrs.merge(:name => name))
    end

    private
      def default_page_parts(config = Radiant::Config)
        default_parts = config['defaults.page.parts'].to_s.strip.split(/\s*,\s*/)
        default_parts.map do |name|
          PagePart.new(:name => name, :filter_id => config['defaults.page.filter'])
        end
      end
  end
  
  @__page_parts = default_page_parts
end
