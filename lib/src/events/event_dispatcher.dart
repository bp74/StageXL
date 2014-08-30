part of stagexl.events;

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

  bool hasEventListenersFor(Event event) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) return false;
    var eventStream = eventStreams[event.type];
    if (eventStream == null) return false;

    if (event.captures && eventStream.hasCapturingSubscriptions) return true;
    if (event.bubbles && eventStream.hasBubblingSubscriptions) return true;
    return eventStream.hasSubscriptions;
  }

  //-----------------------------------------------------------------------------------------------

  /// Adds an event listener to receive events. This style of adding an event listener is used
  /// for an easy migration from legacy ActionScript3 code to Dart code. In pure Dart code you
  /// should consider using the Dart style of adding event listenes like this:
  ///
  /// Example:
  ///
  ///     // ActionScript3 style
  ///     sprite.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
  ///     sprite.addEventListener(MouseEvent.Click, _onMouseClick, useCapture: true);
  ///     sprite.addEventListener("CustomEvent", _onCustomEvent);
  ///
  ///     // Dart style
  ///     sprite.onAddedToStage.listen(_onAddedToStage);
  ///     sprite.onMouseClick.capture(_onMouseClick);
  ///     sprite.on("CustomEvent").listen(_onCustomEvent);
  ///
  StreamSubscription<Event> addEventListener(String eventType, EventListener eventListener, {
    bool useCapture: false, int priority: 0 }) {

    return this.on(eventType)._subscribe(eventListener, useCapture, priority);
  }

  /// Removes an event listener to stop receiving events. This style of removing an event
  /// listener is used for an easy migration from legacy ActionScript3 code to Dart code.
  /// In pure Dart code you should consider using the Dart style of removing event listenes
  /// like this:
  ///
  /// Example:
  ///
  ///     // ActionScript3 style
  ///     sprite.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
  ///     sprite.removeEventListener(MouseEvent.Click, _onMouseClick, useCapture: true);
  ///
  ///     // Dart style
  ///     _onAddedToStageSubscription.cancel();
  ///     _onMouseClickSubscription.cancale();
  ///
  void removeEventListener(String eventType, EventListener eventListener, {
    bool useCapture: false }) {

    this.on(eventType)._unsubscribe(eventListener, useCapture);
  }

  /// Removes all event listeners of a given event type.
  ///
  void removeEventListeners(String eventType) {
    this.on(eventType).cancelSubscriptions();
  }

  /// Dispatches the [event] to all listening subscripers.
  ///
  void dispatchEvent(Event event) {
    dispatchEventRaw(event, this, EventPhase.AT_TARGET);
  }

  //-----------------------------------------------------------------------------------------------

  /// Do not use the [dispatchEventRaw] method unless you want to override the way how events
  /// are dispatched for display list object. Please use the [dispatchEvent] instead.
  ///
  void dispatchEventRaw(Event event, EventDispatcher target, EventPhase eventPhase) {

    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;

    var eventStreams = _eventStreams;
    if (eventStreams == null) return;
    var eventStream = eventStreams[event.type];
    if (eventStream == null) return;

    eventStream._dispatchEventInternal(event, target, eventPhase);
  }

}
