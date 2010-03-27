class PageFactory
  class Manager
    class << self

      def prune_parts!(page_factory=nil)
        [PageFactory, *PageFactory.descendants].select(&by_factory(page_factory)).each do |factory|
          parts = PagePart.scoped(:include => :page).
                           scoped(:conditions => {'pages.page_factory' => name_for(factory)}).
                           scoped(:conditions => ['page_parts.name NOT IN (?)', factory.parts.map(&:name)])
          PagePart.destroy parts
        end
      end

      def update_parts(page_factory=nil)
        [PageFactory, *PageFactory.descendants].select(&by_factory(page_factory)).each do |factory|
          Page.find(:all, :include => :parts, :conditions => {:page_factory => name_for(factory)}).each do |page|
            existing = lambda { |f| page.parts.detect { |p| f.name.downcase == p.name.downcase } }
            page.parts.create factory.parts.reject(&existing).map(&:attributes)
          end
        end
      end

      def sync_parts!(page_factory=nil)
        [PageFactory, *PageFactory.descendants].select(&by_factory(page_factory)).each do |factory|
          Page.find(:all, :include => :parts, :conditions => {:page_factory => name_for(factory)}).each do |page|
            unsynced = lambda { |p| factory.parts.detect { |f| f.name.downcase == p.name.downcase and f.class != p.class } }
            unsynced_parts = page.parts.select(&unsynced)
            page.parts.destroy unsynced_parts
            needs_update = lambda { |f| unsynced_parts.map(&:name).include? f.name }
            page.parts.create factory.parts.select(&needs_update).map &:attributes
          end
        end
      end

      def sync_layouts!(page_factory=nil)
        [PageFactory, *PageFactory.descendants].select(&by_factory(page_factory)).each do |factory|
          Page.update_all({:layout_id => Layout.find_by_name(factory.layout, :select => :id).try(:id)}, {:page_factory => name_for(factory)})
        end
      end

      def sync_classes!(page_factory=nil)
        [PageFactory, *PageFactory.descendants].select(&by_factory(page_factory)).each do |factory|
          Page.update_all({:class_name => factory.page_class}, {:page_factory => name_for(factory)})
        end
      end

      private

        def by_factory(page_factory)
          lambda do |klass|
            page_factory.blank? ? klass.name != 'PageFactory' : klass.name == page_factory.to_s.camelcase
          end
        end

        def name_for(factory)
          factory == PageFactory ? nil : factory.name
        end
    end
  end
end