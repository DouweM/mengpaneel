require "active_support/concern"

require "mengpaneel/manager"

module Mengpaneel
  module Controller
    extend ActiveSupport::Concern

    included do
      prepend_around_action :wrap_in_mengpaneel

      delegate :mixpanel, to: :mengpaneel

      helper_method :mengpaneel, :mixpanel
    end

    def mengpaneel
      @mengpaneel ||= Manager.new(self)
    end

    private
      def wrap_in_mengpaneel(&block)
        mengpaneel.wrap do
          yield
        end
      end
  end
end