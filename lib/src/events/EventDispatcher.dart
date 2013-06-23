part of stagexl;

class EventDispatcher {

  Map<String, _EventStream> _eventStreams;
  Map<String, _EventStream> _captureEventStreams;

  //-----------------------------------------------------------------------------------------------

  bool hasEventListener(String eventType) {
    return _hasEventListener(eventType, true, true);
  }

  StreamSubscription<Event> addEventListener(String eventType, void eventListener(event), {bool useCapture: false}) {
    return _getEventStream(eventType, useCapture).listen(eventListener);
  }

  removeEventListeners(String eventType, {bool useCapture: false}) {
    _getEventStream(eventType, useCapture).cancelSubscriptions();
  }

  dispatchEvent(Event event) {
    _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);
  }

  //-----------------------------------------------------------------------------------------------

  Stream<Event> on(String eventType, {bool useCapture: false}) {
    return _getEventStream(eventType, useCapture);
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool _hasEventListener(String eventType, bool capturingPhase, bool bubblingPhase) {

    if (capturingPhase && _captureEventStreams != null) {
      var eventStream = _captureEventStreams[eventType];
      if (eventStream != null && eventStream._hasSubscriptions) return true;
    }

    if (bubblingPhase && _eventStreams != null) {
      var eventStream = _eventStreams[eventType];
      if (eventStream != null && eventStream._hasSubscriptions) return true;
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  _EventStream _getEventStream(String eventType, bool useCapture) {

    if (useCapture) {
      if (_captureEventStreams == null) _captureEventStreams = new Map<String, _EventStream>();
    } else {
      if (_eventStreams == null) _eventStreams = new Map<String, _EventStream>();
    }

    var eventStreams = useCapture ? _captureEventStreams : _eventStreams;

    return eventStreams.putIfAbsent(eventType, () {
      return new _EventStream(this, eventType, useCapture);
    });
  }

  //-----------------------------------------------------------------------------------------------

  _dispatchEventInternal(Event event, EventDispatcher target, EventDispatcher currentTarget, int eventPhase) {

    var eventStreams = (eventPhase == EventPhase.CAPTURING_PHASE) ? _captureEventStreams : _eventStreams;
    if (eventStreams == null) return;

    var eventStream = eventStreams[event.type];
    if (eventStream == null) return;

    event._target = target;
    event._currentTarget = currentTarget;
    event._eventPhase = eventPhase;
    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;

    eventStream.dispatchEvent(event);
  }

}
