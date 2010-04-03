class PageFactory
  include Annotatable
  annotate :template_name, :layout, :page_class
  template_name 'Page'

  class << self
    attr_accessor :parts, :current_factory

    def inherited(subclass)
      subclass.parts = @parts.dup
      subclass.layout = layout
      subclass.page_class = page_class
      subclass.template_name = subclass.name.to_name('Factory')
    end

    ##
    # Add a part to this PageFactory
    #
    # @param [String] name The name of the page part
    # @param [Hash] attrs A hash of attributes used to construct this part.
    # @option attrs [String] :description Some additional text that will be
    #   shown in the part's tab on the page editing screen. This is used to
    #   display a part description or helper text to editors.
    #
    # @example Add a part with default content and some help text
    #   part 'Sidebar', :content => "Lorem ipsum dolor",
    #                   :description => "This appears in the right-hand sidebar."
    def part(name, attrs={})
      remove name
      @parts << PagePart.new(attrs.merge(:name => name))
    end

    ##
    # Remove a part from this PageFactory
    #
    # @param [<String>] names Any number of part names to remove.
    #
    # @example
    #   remove 'body'
    #   remove 'body', 'extended'
    def remove(*names)
      names = names.map(&:downcase)
      @parts.delete_if { |p| names.include? p.name.downcase }
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
