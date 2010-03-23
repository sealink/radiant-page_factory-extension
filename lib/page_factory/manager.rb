class PageFactory
  class Manager
    class << self
      def prune!
        PageFactory.descendants.each do |factory|
          parts = PagePart.find :all, :include => :page,
                  :conditions => ['pages.page_factory = :factory AND page_parts.name NOT IN (:parts)',
                                  {:factory => factory.name, :parts => factory.parts.map(&:name)}
                                 ]
          PagePart.destroy parts
        end
      end
    end
  end
end