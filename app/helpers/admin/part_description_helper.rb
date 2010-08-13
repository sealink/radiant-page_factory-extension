module Admin::PartDescriptionHelper
  def description_for(part)
    return nil if @page.nil?
    @page.class.parts.detect do |f|
      f.name.downcase == part.name.downcase and
      f.class == part.class
    end.try(:description)
  end
end