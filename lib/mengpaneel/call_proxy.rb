module Mengpaneel
  class CallProxy
    attr_reader :method_name
    attr_reader :args
    attr_reader :calls

    def initialize(method_name = nil, args = [])
      @method_name  = method_name
      @args         = args

      @calls = []
    end

    def method_missing(method_name, *args)
      save_call(method_name, *args)
    end

    def respond_to_missing?(method_name, include_private = false)
      true
    end

    def full_method_name(prefixes)
      [*prefixes, *self.method_name]
    end

    def to_call(prefixes = [])
      [full_method_name(prefixes), args] if self.method_name
    end

    def child_calls(prefixes = [])
      method_name = full_method_name(prefixes)
      @calls.flat_map { |proxy| proxy.all_calls(method_name) }
    end

    def all_calls(prefixes = [])
      calls = []
      calls << to_call(prefixes) if self.method_name && (@calls.empty? || !@args.empty?)
      calls += child_calls(prefixes)
      calls
    end

    private
      def save_call(method_name, *args)
        proxy = self.class.new(method_name, args)

        @calls << proxy

        proxy
      end
  end
end