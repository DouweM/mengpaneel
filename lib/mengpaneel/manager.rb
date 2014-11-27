require "mengpaneel/call_proxy"
require "mengpaneel/replayer"
require "mengpaneel/flusher"

module Mengpaneel
  class Manager
    MODES = %w(before_setup setup tracking).map(&:to_sym).freeze

    attr_reader   :controller
    attr_reader   :mode

    attr_accessor :flushing_strategy

    def initialize(controller = nil, &block)
      @controller = controller

      @mode = :tracking

      wrap(&block) if block
    end

    def wrap(&block)
      replay_delayed_calls
      
      if block.arity == 1
        yield(self)
      else
        yield
      end
    ensure
      flush_calls
    end

    def call_proxy
      call_proxies[@mode]
    end
    alias_method :mixpanel, :call_proxy

    def clear_calls(mode = @mode)
      call_proxies.delete(mode)
    end

    def all_calls
      Hash[call_proxies.map { |mode, call_proxy| [mode, call_proxy.all_calls] }]
    end

    def with_mode(mode, &block)
      original_mode = @mode
      @mode = mode

      begin
        if block.arity == 1
          yield(mixpanel)
        else
          yield
        end
      ensure
        @mode = original_mode
      end
    end

    def before_setup(&block)
      with_mode(:before_setup, &block)
    end

    def setup(&block)
      clear_calls(:setup)
      with_mode(:setup, &block)
    end

    def tracking(&block)
      with_mode(:tracking, &block)
    end

    def setup?
      call_proxies[:setup].all_calls.length > 0
    end

    def replay_delayed_calls
      Replayer.new(self).run
    end

    def flush_calls
      Flusher.new(self).run
    end

    private
      def call_proxies
        @call_proxies ||= Hash.new { |proxies, mode| proxies[mode] = CallProxy.new }
      end
  end
end