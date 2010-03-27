class PageFactory
  class Manager
    class << self

      def prune!(klass=nil)
        by_factory = lambda do |descendant|
          klass.nil? ? true : descendant.name == klass.to_s.camelcase
        end
        PageFactory.descendants.select(&by_factory).each do |factory|
          parts = PagePart.find :all, :include => :page,
                  :conditions => ['pages.page_factory = :factory AND page_parts.name NOT IN (:parts)',
                                  {:factory => factory.name, :parts => factory.parts.map(&:name)}
                                 ]
          PagePart.destroy parts
        end
      end

      def update_parts
        PageFactory.descendants.each do |factory|
          Page.find_all_by_page_factory(factory.name, :include => :parts).each do |page|
            existing = lambda { |f| page.parts.dup.find { |p| f.name == p.name and f.class == p.class } }
            page.parts.create factory.parts.reject(&existing).map(&:attributes)
          end
        end
      end
    end
  end
end