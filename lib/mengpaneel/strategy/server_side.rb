require "mengpaneel/strategy/base"
require "mengpaneel/tracker"

module Mengpaneel
  module Strategy
    class ServerSide < Base
      def initialize(all_calls, controller = nil, remote_ip = nil)
        super(all_calls, controller)

        @remote_ip = remote_ip || controller.try(:request).try(:remote_ip)
      end

      def run
        return true if all_calls[:tracking].blank?

        perform_calls(:before_setup)
        perform_calls(:setup)
        perform_calls(:tracking)

        true
      end

      private
        def tracker
          @tracker ||= Tracker.new(Mengpaneel.token, @remote_ip)
        end

        def perform_calls(mode)
          calls = all_calls[mode] || []

          calls.each do |method_names, args|
            method_name = method_names.pop

            object = method_names.inject(tracker) { |object, method_name| object.public_send(method_name) }

            object.public_send(method_name, *args)
          end
        end
    end
  end
end