(function($, undefined) {
  var REQUEST_HEADER  = "X-Mengpaneel-Flush-Capable";
  var RESPONSE_HEADER = "X-Mengpaneel-Calls";

  if (!window.mixpanel) return;

  $(document).on("ajaxSend", function(event, xhr, options) {
    if (options.crossDomain) return;

    xhr.setRequestHeader(REQUEST_HEADER, "true");
  });

  $(document).on("ajaxComplete", function(event, xhr, options) {
    if (options.crossDomain) return;

    var rawCalls = xhr.getResponseHeader(RESPONSE_HEADER);
    if (!rawCalls) return;

    var calls;
    try { 
      calls = $.parseJSON(rawCalls);
    }
    catch (e) {
      return;
    }

    for(var i = 0, length = calls.length; i < length; i++) {
      var call = calls[i];
      var methodNames = call[0];
      var args = call[1];

      var object = window.mixpanel;
      if (!object) return;

      var methodName = methodNames.pop();

      for(var j = 0, length2 = methodNames.length; j < length2; j++) {
        var name = methodNames[j];

        object = object[name];
      }

      var method = object[methodName];

      method.apply(object, args);
    }
  });
})(jQuery);