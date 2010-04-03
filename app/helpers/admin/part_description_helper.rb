module Admin::PartDescriptionHelper
  def description_for(part)
    return nil if @page.nil? or @page.page_factory.blank?
    begin
      factory = @page.page_factory.constantize
    rescue NameError => e # @page.page_factory is not a constant. class was removed?
      logger.warn "Couldn't find page factory: #{e.message}"
      factory = PageFactory::Base
    end
    factory.parts.detect do |f|
      f.name.downcase == part.name.downcase and
      f.class == part.class
    end.try :description
  end
end