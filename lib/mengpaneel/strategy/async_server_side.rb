require "mengpaneel/strategy/base"
require "mengpaneel/strategy/server_side"

module Mengpaneel
  module Strategy
    class AsyncServerSide < Base
      def run
        return false unless self.class.async?

        return true if all_calls[:tracking].blank?

        MengPaneelWorker.perform_later(all_calls, controller.try(:request).try(:remote_ip))

        true
      end

      private
        def self.async?
          defined?(::ActiveJob)
        end

      if async?
        class MengPaneelWorker < ::ActiveJob::Base
          queue_as :default

          def perform(all_calls, remote_ip = nil)
            all_calls = all_calls.with_indifferent_access

            Strategy::ServerSide.new(all_calls, nil, remote_ip).run
          end
        end
      end
    end
  end
end