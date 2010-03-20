class PageFactory

  class << self
    attr_accessor :current_factory

    def parts
      (@current_factory || self).instance_variable_get :@page_parts
    end

    def inherited(subclass)
      subclass.instance_variable_set :@page_parts, @page_parts.dup
    end

    def part(name, attrs={})
      @page_parts.delete_if { |p| name == p.name }
      @page_parts << PagePart.new(attrs.merge(:name => name))
    end

    private
      def default_page_parts(config = Radiant::Config)
        default_parts = config['defaults.page.parts'].to_s.strip.split(/\s*,\s*/)
        default_parts.map do |name|
          PagePart.new(:name => name, :filter_id => config['defaults.page.filter'])
        end
      end
  end
  
  @page_parts = default_page_parts
end
