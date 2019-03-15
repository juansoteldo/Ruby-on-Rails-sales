(function ($) {

  let $eventInfo;

  const getTrackerClientId = function() {
    try {
      const trackers = ga.getAll();
      let i, len;
      for (i = 0, len = trackers.length; i < len; i += 1) {
        if (trackers[i].get('trackingId') === 'UA-34117074-2') {
          return trackers[i].get('clientId');
        }
      }
    } catch(e) {}
    return 'false';
  };

  const saveClientId = function(clientId) {
    const request = $eventInfo.data('request');
    const patch = {
      request: {
        client_id: clientId
      }
    };
    $.ajax({
      type: 'PATCH',
      url: Routes.api_request_path(request.id, { uuid: request.uuid }),
      data: patch
    });
  };

  const updateRequest = function() {
    const clientId = getTrackerClientId();

    if (!clientId) return;
    saveClientId(clientId);
  };

  let iterations = 0;

  const runWhenAnalyticsLoaded = function(method) {
    if (window._gaq && window._gaq._getTracker) {
      method.call();
    } else {
      iterations += 1;
      if (iterations === 5) return;
      setTimeout(() => runWhenAnalyticsLoaded(method), 500);
    }
  };

  const ready = function() {
    $eventInfo = $('.event_info');
    if ($eventInfo.length === 0) return;
    runWhenAnalyticsLoaded(updateRequest);
  };

  $(document).ready(ready);
  $(document).on('turbolinks:load', ready);
}(jQuery));


