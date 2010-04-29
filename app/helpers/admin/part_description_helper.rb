module Admin::PartDescriptionHelper
  def description_for(part)
    return nil if @page.nil? or @page.page_factory.blank?
    @page.page_factory.parts.detect do |f|
      f.name.downcase == part.name.downcase and
      f.class == part.class
    end.try :description
  end
end