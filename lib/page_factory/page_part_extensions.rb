module PageFactory
  module PagePartExtensions
    def self.included(base)
      base.class_eval do
        attr_accessor :description
      end
    end
  end
end