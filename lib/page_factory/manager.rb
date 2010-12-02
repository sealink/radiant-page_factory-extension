module PageFactory
  ##
  # PageFactory::Manager is used to update your existing content with changes
  #   subsequently made to your Page classes. All of these methods take a single
  #   optional argument, which should be the name of a Page class.
  #
  #   If a class name is given, only pages of that class are affected. If no
  #   argument is given, the method is run for Page and all of its subclasses.
  class Manager
    class << self
      ##
      # Remove parts not specified in a Page class from all instances of that class.
      #   This is useful if you decide to remove a part from a Page class and you
      #   want your previously created pages to reflect that removal.
      #
      # @param [nil, String, Symbol, #to_s] klass The Page class to restrict
      # this method to, or nil to run on Page and all of its descendants.
      def prune_parts!(klass=nil)
        select_class(klass).each do |subclass|
          parts = PagePart.scoped(:include => :page).
                           scoped(:conditions => {'pages.class_name' => name_for(subclass)}).
                           scoped(:conditions => ['page_parts.name NOT IN (?)', subclass.parts.map(&:name)])
          PagePart.destroy parts
        end
      end

      ##
      # Add any parts defined in a Page class to all instances of that class,
      #   if those records are missing any parts. This can be used when you've 
      #   added a part to a class and you want your existing content to reflect
      #   that change.
      #
      # @param [nil, String, Symbol, #to_s] klass The Page class to operate on,
      #   or nil to run it on Page and all of its descendants.
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
      #   the parts defined in the Page's class. Mismatched parts will be replaced
      #   with wholly new parts of the proper class -- this method _will_
      #   discard content. Unless you're using an extension that subclasses
      #   PagePart (this is rare) you won't need this method.
      #
      # @param [nil, String, Symbol, #to_s] klass The Page class to operate on,
      #   or nil to run it on Page and all of its descendants.
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
      # Add any fields defined on a Page class to all instances of that class,
      #   should those fields be missing. This can be useful when you've added
      #   a field to a Page class and you want your existing content to reflect
      #   that change.
      #
      # @param [nil, String, Symbol, #to_s] klass The Page class to operate on,
      #   or nil to run it on Page and all of its descendants.
      def update_fields(klass=nil)
        select_class(klass).each do |subclass|
          Page.find(:all, :include => :fields, :conditions => {:class_name => name_for(subclass)}).each do |page|
            existing = lambda { |s| page.fields.detect { |p| s.name.downcase == p.name.downcase } }
            page.fields.create subclass.fields.reject(&existing).map(&:attributes)
          end
        end
      end

      def prune_fields!(klass=nil)
        select_class(klass).each do |subclass|
          fields = Page.scoped(:include => :fields).
                        scoped(:conditions => {:class_name => name_for(subclass)}).
                        scoped(:conditions => ['page_fields.name NOT IN (?)', subclass.fields.map(&:name)]).
                        map(&:fields).flatten
          PageField.destroy fields
        end
      end

      ##
      # Update the layout of all instances of a Page class to match the layout
      #   specified by the class. Used when you want to use a new layout for
      #   a specific Page class and need to update your existing content.
      #
      # @param [nil, String, Symbol, #to_s] klass The Page class to operate on,
      #   or nil to run it on Page and all of its descendants.
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
