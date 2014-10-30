require "active_support/hash_with_indifferent_access"
require "mixpanel-ruby"

module Mengpaneel
  class Tracker < Mixpanel::Tracker
    attr_reader :token
    attr_reader :remote_ip
    attr_reader :distinct_id

    def initialize(token, remote_ip = nil)
      super(token)
      @people = People.new(self)

      @remote_ip = remote_ip

      @disable_all_events = false
      @disabled_events = []

      @properties = HashWithIndifferentAccess.new
      @properties["ip"] = @remote_ip if @remote_ip
    end

    def push(item)
      method_name, args = item
      send(method_name, *args)
    end

    def disable(events = nil)
      if events
        @disabled_events += events
      else
        @disable_all_events = true
      end
    end

    def identify(distinct_id)
      @distinct_id = distinct_id
    end

    def register(properties)
      @properties.merge!(properties)
    end

    def register_once(properties, default_value = "None")
      @properties.merge!(properties) do |key, oldval, newval|
        oldval.nil? || oldval == default_value ? newval : oldval
      end
    end

    def unregister(property)
      @properties.delete(property)
    end

    def get_property(property)
      @properties[property]
    end

    def track(event, properties = {})
      return if @disable_all_events || @disabled_events.include?(event)

      properties = @properties.merge(properties)

      super(@distinct_id, event, properties)
    end

    %i(track_links track_forms alias set_config get_config).each do |name|
      define_method(name) do |*args|
        # Not supported on server side
      end
    end

    class People < Mixpanel::People
      attr_reader :tracker

      def initialize(tracker)
        @tracker = tracker
        
        super(tracker.token)
      end

      %i(set set_once increment append track_charge clear_charges delete_user).each do |method_name|
        define_method(method_name) do |*args|
          args.unshift(tracker.distinct_id) unless args.first == tracker.distinct_id
          super(*args)
        end
      end

      def update(message)
        message["$ip"] = tracker.remote_ip

        super(message)
      end
    end
  end
end