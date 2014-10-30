module Mengpaneel
  class Delayer
    SESSION_KEY = "mengpaneel_delayed_calls".freeze

    attr_reader :controller

    def initialize(controller = nil)
      @controller = controller
    end

    def load
      (controller.session[SESSION_KEY] || {}).with_indifferent_access
    end

    def load!
      calls = load
      controller.session.delete(SESSION_KEY)
      calls
    end

    def save(all_calls)
      controller.session[SESSION_KEY] = all_calls
    end
  end
end