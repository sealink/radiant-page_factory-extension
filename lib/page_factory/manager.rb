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
      def prune_parts!(page_factory=nil)
        select_factories(page_factory).each do |factory|
          parts = PagePart.scoped(:include => :page).
                           scoped(:conditions => {'pages.page_factory' => name_for(factory)}).
                           scoped(:conditions => ['page_parts.name NOT IN (?)', factory.parts.map(&:name)])
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
      def update_parts(page_factory=nil)
        select_factories(page_factory).each do |factory|
          Page.find(:all, :include => :parts, :conditions => {:page_factory => name_for(factory)}).each do |page|
            existing = lambda { |f| page.parts.detect { |p| f.name.downcase == p.name.downcase } }
            page.parts.create factory.parts.reject(&existing).map(&:attributes)
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
      def sync_parts!(page_factory=nil)
        select_factories(page_factory).each do |factory|
          Page.find(:all, :include => :parts, :conditions => {:page_factory => name_for(factory)}).each do |page|
            unsynced = lambda { |p| factory.parts.detect { |f| f.name.downcase == p.name.downcase and f.class != p.class } }
            unsynced_parts = page.parts.select(&unsynced)
            page.parts.destroy unsynced_parts
            needs_update = lambda { |f| unsynced_parts.map(&:name).include? f.name }
            page.parts.create factory.parts.select(&needs_update).map &:attributes
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
      def sync_layouts!(page_factory=nil)
        select_factories(page_factory).each do |factory|
          Page.update_all({:layout_id => Layout.find_by_name(factory.layout, :select => :id).try(:id)}, {:page_factory => name_for(factory)})
        end
      end

      ##
      # Update the Page class of all pages initially created by a PageFactory
      #   to match the class currently specified on that PageFactory. Useful
      #   when you assign a new page class to a PageFactory and you want your
      #   existing content to reflect that change.
      #
      # @param [nil, String, Symbol, #to_s] page_factory The PageFactory to
      #   restrict this operation to, or nil to run it on all PageFactories.
      def sync_classes!(page_factory=nil)
        select_factories(page_factory).each do |factory|
          Page.update_all({:class_name => factory.page_class}, {:page_factory => name_for(factory)})
        end
      end

      private

        def select_factories(page_factory)
          [PageFactory::Base, *PageFactory::Base.descendants].select do |klass|
            case page_factory
            when '', nil
              klass.name != 'PageFactory::Base'
            when 'PageFactory', :PageFactory
              klass.name == 'PageFactory::Base'
            else 
              klass.name == page_factory.to_s.camelcase
            end
          end
        end

        def name_for(factory)
          factory == PageFactory::Base ? nil : factory.name
        end
    end
  end
end