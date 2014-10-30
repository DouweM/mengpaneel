require "mengpaneel/delayer"

module Mengpaneel
  class Replayer
    attr_reader :manager

    def initialize(manager)
      @manager = manager
    end

    def run
      return unless manager.controller
      
      delayed_calls = Delayer.new(manager.controller).load!

      Manager::MODES.each do |mode|
        next unless delayed_calls.has_key?(mode)

        calls = delayed_calls[mode] || []

        manager.send(mode) do
          replay_calls(calls)
        end
      end
    end

    private
      def replay_calls(calls)
        proxy = manager.call_proxy

        calls.each do |method_names, args|
          method_name = method_names.pop

          object = method_names.inject(proxy) { |object, method_name| object.public_send(method_name) }
          
          object.public_send(method_name, *args)
        end
      end
  end
end