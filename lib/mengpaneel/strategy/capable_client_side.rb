require "mengpaneel/strategy/base"

module Mengpaneel
  module Strategy
    class CapableClientSide < Base
      REQUEST_HEADER  = "X-Mengpaneel-Flush-Capable".freeze
      RESPONSE_HEADER = "X-Mengpaneel-Calls".freeze

      delegate :request, :response, to: :controller, allow_nil: true

      def run
        return false unless controller
        return false unless capable?

        return true if all_calls[:tracking].blank?

        response.headers[RESPONSE_HEADER] = JSON.dump(all_calls[:tracking])

        true
      end

      private
        def capable?
          %w(true 1).include?(request.headers[REQUEST_HEADER])
        end
    end
  end
end