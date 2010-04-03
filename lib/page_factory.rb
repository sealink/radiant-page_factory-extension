module PageFactory
  def self.current_factory
    @current_factory ||= PageFactory::Base
  end

  def self.current_factory=(factory)
    factory = factory.constantize if factory.is_a?(String)
    if factory.nil? or factory <= PageFactory::Base
      @current_factory = factory
    end
  end
end
