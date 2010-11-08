module PageFactory
  ##
  # PageFactory::Manager is used to update your existing content with changes
  #   subsequently made to your PageFactories. All of these methods take a single
  #   optional argument, which should be the name of a PageFactory class.
  #
  #   If no argument is given, the method is run for all PageFactories.
  #   Plain old pages not created with a specific factory are never affected in
  #   this case. If the name of a PageFactory is given, the method is only run
  #   on pages that were initially created by the specified PageFactory.
  #
  #   Note that it is possible to pass 'page' as an argument, if you really
  #   need to update pages that were created without a specific factory.
  class Manager
    class << self

      ##
      # Remove parts not specified in a PageFactory from all pages initially
      #   created by that PageFactory. This is useful if you decide to remove
      #   a part from a PageFactory and you want your existing content to
      #   reflect that change.
      #
      # @param [nil, String, Symbol, #to_s] page_factory The PageFactory to
      #   restrict this operation to, or nil to run it on all PageFactories.
      def prune_parts!(klass=nil)
        select_class(klass).each do |subclass|
          parts = PagePart.scoped(:include => :page).
                           scoped(:conditions => {'pages.class_name' => name_for(subclass)}).
                           scoped(:conditions => ['page_parts.name NOT IN (?)', subclass.parts.map(&:name)])
          PagePart.destroy parts
        end
      end

      ##
      # Add any parts defined in a PageFactory to all pages initially created
      #   by that factory, if those pages are missing any parts. This can be
      #   used when you've added a part to a factory and you want your existing
      #   content to reflect that change.
      #
      # @param [nil, String, Symbol, #to_s] page_factory The PageFactory to
      #   restrict this operation to, or nil to run it on all PageFactories.
      def update_parts(klass=nil)
        select_class(klass).each do |subclass|
          Page.find(:all, :include => :parts, :conditions => {:class_name => name_for(subclass)}).each do |page|
            existing = lambda { |s| page.parts.detect { |p| s.name.downcase == p.name.downcase } }
            page.parts.create subclass.parts.reject(&existing).map(&:attributes)
          end
        end
      end

      ##
      # Replace any parts on a page that share a _name_ but not a _class_ with
      #   the parts defined in its PageFactory. Mismatched parts will be
      #   replaced with wholly new parts of the proper class -- this method
      #   _will_ discard content. Unless you're using an extension that
      #   subclasses PagePart (this is rare) you won't need this method.
      #
      # @param [nil, String, Symbol, #to_s] page_factory The PageFactory to
      #   restrict this operation to, or nil to run it on all PageFactories.
      def sync_parts!(klass=nil)
        select_class(klass).each do |subclass|
          Page.find(:all, :include => :parts, :conditions => {:class_name => name_for(subclass)}).each do |page|
            unsynced = lambda { |p| subclass.parts.detect { |s| s.name.downcase == p.name.downcase and s.class != p.class } }
            unsynced_parts = page.parts.select(&unsynced)
            page.parts.destroy unsynced_parts
            needs_update = lambda { |s| unsynced_parts.map(&:name).include? s.name }
            page.parts.create subclass.parts.select(&needs_update).map &:attributes
          end
        end
      end

      ##
      # Update the layout of all pages initially created by a PageFactory to
      #   match the layout currently specified on that PageFactory. Used when
      #   you decide to use a new layout in a PageFactory and you want your
      #   existing content to reflect that change.
      #
      # @param [nil, String, Symbol, #to_s] page_factory The PageFactory to
      #   restrict this operation to, or nil to run it on all PageFactories.
      def sync_layouts!(klass=nil)
        select_class(klass).each do |subclass|
          Page.update_all({:layout_id => Layout.find_by_name(subclass.layout, :select => :id).try(:id)}, {:class_name => name_for(subclass)})
        end
      end

      private

        def select_class(klass)
          klass.blank? ? [Page, *Page.descendants] : [klass.to_s.camelcase.constantize]
        end

        def name_for(klass)
          klass == Page ? nil : klass.name
        end
    end
  end
end
