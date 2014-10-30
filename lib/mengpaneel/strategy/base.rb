module Mengpaneel
  module Strategy
    class Base
      attr_reader :all_calls
      attr_reader :controller

      def initialize(all_calls, controller = nil)
        @all_calls  = all_calls
        @controller = controller
      end

      def run
        raise NotImplementedError
      end
    end
  end
end