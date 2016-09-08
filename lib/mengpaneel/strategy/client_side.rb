require "active_support/core_ext/string/strip"
require "mengpaneel/strategy/base"

module Mengpaneel
  module Strategy
    class ClientSide < Base
      SETUP_CODE = <<-CODE.strip_heredoc
        (function(f,b){if(!b.__SV){var a,e,i,g;window.mixpanel=b;b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ");
        for(g=0;g<i.length;g++)f(c,i[g]);b._i.push([a,e,d])};b.__SV=1.2;a=f.createElement("script");a.type="text/javascript";a.async=!0;a.src="//cdn.mxpnl.com/libs/mixpanel-2.2.min.js";e=f.getElementsByTagName("script")[0];e.parentNode.insertBefore(a,e)}})(document,window.mixpanel||[]);
      CODE

      delegate :request, :response, to: :controller, allow_nil: true

      def run
        return false unless controller
        return false unless client_side?

        response_body = response.body

        head_end = response_body.index("</head")
        return false unless head_end

        if source = source_for_head
          response_body.insert(head_end, source)
        end

        body_end = response_body.index("</body")
        return false unless body_end

        if source = source_for_body
          response_body.insert(body_end, source)
        end

        response.body = response_body

        true
      end
      
      def env
        request.env
      end

      private
        def source_for_head
          [
            %{<script type="text/javascript">},
              SETUP_CODE,

              %{mixpanel.init(#{Mengpaneel.token.to_json});},
              
              *javascript_calls(:before_setup),
              *javascript_calls(:setup),
            %{</script>}
          ].join("\n")
        end

        def source_for_body
          return if all_calls[:tracking].blank?

          [
            %{<script type="text/javascript">},
              *javascript_calls(:tracking),
            %{</script>}
          ].join("\n")
        end

        def javascript_calls(mode)
          calls = all_calls[mode] || []

          calls.map do |method_names, args|
            method_name = method_names.join(".")
            arguments   = args.map(&:to_json).join(", ")

            %{mixpanel.#{method_name}(#{arguments});}
          end
        end

        def client_side?
          html? && !request.xhr? && !attachment? && !streaming?
        end

        def html?
          response.content_type && response.content_type.include?("text/html")
        end

        def attachment?
          response.headers["Content-Disposition"].to_s.include?("attachment")
        end

        def streaming?
          return false unless defined?(ActionController::Live)

          env["action_controller.instance"].class.included_modules.include?(ActionController::Live)
        end
    end
  end
end
