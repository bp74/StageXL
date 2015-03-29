part of stagexl.events;

/// The base class for all classes that dispatch events.
///
/// The [EventDispatcher] class is the base class for the [DisplayObject] class.
/// The [EventDispatcher] class allows any object on the display list to be an
/// event target.
///
/// Event targets are an important part of the StageXL event model. The event
/// target serves as the focal point for how events flow through the display
/// list hierarchy. When an event such as a mouse click or a keypress occurs,
/// the application dispatches an event object into the event flow from the root
/// of the display list. The event object then makes its way through the display
/// list until it reaches the event target, at which point it begins its return
/// trip through the display list. This round-trip journey to the event target
/// is conceptually divided into three phases:
///
/// * the capture phase comprises the journey from the root to the last node
///   before the event target's node,
/// * the target phase comprises only the event target node, and
/// * the bubbling phase comprises any subsequent nodes encountered on the
///   return trip to the root of the display list.
///
/// In general, the easiest way for a user-defined class to gain event
/// dispatching capabilities is to extend [EventDispatcher]. If this is
/// impossible (that is, if the class is already extending another class), you
/// can instead use the [EventDispatcher] as a mixin.

class EventDispatcher {

  Map<String, EventStream> _eventStreams;

  //----------------------------------------------------------------------------

  /// Returns an event stream of type [eventType].
  ///
  /// This accessor should only be used when an explicit accessor is not
  /// available, e.g. for custom events:
  ///
  ///     sprite.onAddedToStage.listen(_onAddedToStage);
  ///     sprite.onMouseClick.capture(_onMouseClick);
  ///     sprite.on("CustomEvent").listen(_onCustomEvent);

  EventStream<Event> on(String eventType) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) {
      eventStreams = new Map<String, EventStream>();
      _eventStreams = eventStreams;
    }

    var eventStream = eventStreams[eventType];
    if (eventStream == null) {
      eventStream = new EventStream._(this, eventType);
      eventStreams[eventType] = eventStream;
    }

    return eventStream;
  }

  //----------------------------------------------------------------------------

  /// Returns true if the [EventDispatcher] has event listeners. The
  /// [useCapture] paramenter defines if the event listeners should be
  /// registered for the capturing event phase or not.

  bool hasEventListener(String eventType, { bool useCapture: false }) {

    var eventStreams = _eventStreams;
    if (eventStreams == null) return false;
    var eventStream = eventStreams[eventType];
    if (eventStream == null) return false;

    return useCapture
        ? eventStream.hasCapturingSubscriptions
        : eventStream.hasBubblingSubscriptions;
  }

  //----------------------------------------------------------------------------

  /// Adds an event listener to receive events.
  ///
  /// This style of adding an event listener is used for an easy migration from
  /// legacy ActionScript3 code to Dart code. In pure Dart code you should
  /// consider using the Dart style of adding event listenes like this:
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

  StreamSubscription<Event> addEventListener(
      String eventType, EventListener eventListener, {
      bool useCapture: false, int priority: 0 }) {

    return this.on(eventType)._subscribe(eventListener, useCapture, priority);
  }

  /// Removes an event listener to stop receiving events.
  ///
  /// This style of removing an event listener is used for an easy migration
  /// from legacy ActionScript3 code to Dart code. In pure Dart code you should
  /// consider using the Dart style of removing event listenes like this:
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

  void removeEventListener(String eventType, EventListener eventListener, {
    bool useCapture: false }) {

    this.on(eventType)._unsubscribe(eventListener, useCapture);
  }

  /// Removes all event listeners of a given event type.

  void removeEventListeners(String eventType) {
    this.on(eventType).cancelSubscriptions();
  }

  /// Dispatches the [event] to all listening subscribers.

  void dispatchEvent(Event event) {
    dispatchEventRaw(event, this, EventPhase.AT_TARGET);
  }

  //----------------------------------------------------------------------------

  /// Do not use the [dispatchEventRaw] method unless you want to override the
  /// way how events are dispatched for display list object. Please use
  /// [dispatchEvent] instead.

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
