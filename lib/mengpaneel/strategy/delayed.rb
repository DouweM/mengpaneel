require "mengpaneel/strategy/base"
require "mengpaneel/delayer"

module Mengpaneel
  module Strategy
    class Delayed < Base
      def run
        return false unless controller
        return false unless redirect?

        Delayer.new(controller).save(all_calls)

        true
      end

      private
        def redirect?
          (300...400).include?(controller.response.status)
        end
    end
  end
end