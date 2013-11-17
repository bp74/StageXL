part of stagexl;

class EventDispatcher {

  Map<String, EventStream> _eventStreams;

  //-----------------------------------------------------------------------------------------------

  EventStream<Event> on(String eventType) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) {
      eventStreams = new Map<String, EventStream>();
      _eventStreams = eventStreams;
    }

    var eventStream = eventStreams[eventType];
    if (eventStream == null) {
      eventStream = new EventStream._internal(this, eventType);
      eventStreams[eventType] = eventStream;
    }

    return eventStream;
  }

  //-----------------------------------------------------------------------------------------------

  bool hasEventListener(String eventType) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) return false;
    var eventStream = eventStreams[eventType];
    if (eventStream == null) return false;

    return eventStream.hasSubscriptions;
  }

  StreamSubscription<Event> addEventListener(
      String eventType, EventListener eventListener, { bool useCapture: false }) {

    return useCapture
        ? this.on(eventType).capture(eventListener)
        : this.on(eventType).listen(eventListener);
  }

  void removeEventListeners(String eventType) {
    this.on(eventType).cancelSubscriptions();
  }

  void dispatchEvent(Event event) {
    _dispatchEventInternal(event, this, EventPhase.AT_TARGET);
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool _hasPropagationEventListeners(Event event) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) return false;
    var eventStream = eventStreams[event.type];
    if (eventStream == null) return false;

    return eventStream._hasPropagationSubscriptions(event);
  }

  _dispatchEventInternal(Event event, EventDispatcher target, int eventPhase) {

    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;

    var eventStreams = _eventStreams;
    if (eventStreams == null) return;
    var eventStream = eventStreams[event.type];
    if (eventStream == null) return;

    eventStream._dispatchEventInternal(event, target, eventPhase);
  }

}
