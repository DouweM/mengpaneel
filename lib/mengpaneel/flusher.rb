require "mengpaneel/strategy/delayed"
require "mengpaneel/strategy/client_side"
require "mengpaneel/strategy/capable_client_side"
require "mengpaneel/strategy/async_server_side"
require "mengpaneel/strategy/server_side"

module Mengpaneel
  class Flusher
    STRATEGIES = [
      Strategy::Delayed,
      Strategy::ClientSide,
      Strategy::CapableClientSide,
      Strategy::AsyncServerSide,
      Strategy::ServerSide
    ]

    attr_reader :manager

    def initialize(manager)
      @manager = manager
    end

    def run
      return unless Mengpaneel.token
      
      if manager.flushing_strategy
        strategy = Strategy.const_get(manager.flushing_strategy.to_s.classify)
        flush_using(strategy)
      else
        STRATEGIES.find { |strategy| flush_using(strategy) }
      end
    end

    private
      def flush_using(strategy)
        strategy.new(manager.all_calls, manager.controller).run
      end
  end
end