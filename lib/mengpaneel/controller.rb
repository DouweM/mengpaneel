require "active_support/concern"

require "mengpaneel/manager"

module Mengpaneel
  module Controller
    extend ActiveSupport::Concern

    included do
      if Rails::VERSION::MAJOR >= 5
        prepend_around_action :wrap_in_mengpaneel
      else
        prepend_around_filter :wrap_in_mengpaneel
      end

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
