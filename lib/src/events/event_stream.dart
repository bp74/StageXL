part of stagexl.events;

/// Provides a stream of [Event]s.
class EventStream<T extends Event> extends Stream<T> {

  /// The event target.
  final EventDispatcher target;

  /// The event type of this stream.
  final String eventType;

  // We store the subscriptions in a immutable fixed length list.
  // If subscriptions are added or canceled we create a new list.
  // This is safe and gives good performance in JavaScript.

  List<EventStreamSubscription> _subscriptions = new List(0);
  int _capturingSubscriptionCount = 0;

  EventStream._(this.target, this.eventType);

  //----------------------------------------------------------------------------

  @override
  bool get isBroadcast => true;

  @override
  Stream<T> asBroadcastStream({
    void onListen(StreamSubscription subscription),
    void onCancel(StreamSubscription subscription)}) => this;

  bool get hasSubscriptions => _subscriptions.length > 0;
  bool get hasCapturingSubscriptions => _capturingSubscriptionCount > 0;
  bool get hasBubblingSubscriptions => _subscriptions.length > _capturingSubscriptionCount;

  //----------------------------------------------------------------------------

  /// Adds a subscription to this stream that processes the event during the
  /// target or bubbling phase.
  ///
  /// In contrast, the [capture] method processes the event during the capture
  /// phase.
  ///
  /// On each data event from this stream, the subscriber's [onData] handler
  /// is called.
  ///
  /// The [priority] level of the event listener can be specified. The higher
  /// the number, the higher the priority. All listeners with priority n are
  /// processed before listeners of priority n-1. If two or more listeners share
  /// the same priority, they are processed in the order in which they were
  /// added. The default priority is 0.
  ///
  /// Note: The [onError] and [onDone] handlers and [cancelOnError] are not used
  /// as the stream has no errors and is never done.

  @override
  EventStreamSubscription<T> listen(void onData(T event), {
    void onError(error), void onDone(),
    bool cancelOnError: false, int priority: 0 }) {

    return _subscribe(onData, false, priority);
  }

  //----------------------------------------------------------------------------

  /// Adds a subscription to this stream that processes the event during the
  /// capture phase.
  ///
  /// In contrast, the [listen] method processes the event during the target or
  /// bubbling phase.
  ///
  /// On each data event from this stream, the subscriber's [onData] handler
  /// is called.
  ///
  /// The [priority] level of the event listener can be specified. The higher
  /// the number, the higher the priority. All listeners with priority n are
  /// processed before listeners of priority n-1. If two or more listeners share
  /// the same priority, they are processed in the order in which they were
  /// added. The default priority is 0.

  EventStreamSubscription<T> capture(void onData(T event), { int priority: 0 }) {
    return _subscribe(onData, true, priority);
  }

  //----------------------------------------------------------------------------

  /// Cancels all subscriptions to this stream.

  void cancelSubscriptions() {

    var subscriptions = _subscriptions;

    for(int i = 0; i < subscriptions.length; i++) {
      _cancelSubscription(subscriptions[i]);
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  EventStreamSubscription<T> _subscribe(
      EventListener eventListener, bool captures, int priority) {

    var subscription = new EventStreamSubscription<T>._(this,
        eventListener, captures, priority);

    // Insert the new subscription according to its priority.

    var oldSubscriptions = _subscriptions;
    var newSubscriptions = new List(oldSubscriptions.length + 1);
    var index = newSubscriptions.length - 1;

    for(int o = 0, n = 0; o < oldSubscriptions.length; o++) {
      var oldSubscription = oldSubscriptions[o];
      if (o == n && oldSubscription.priority < priority) index = n++;
      newSubscriptions[n++] = oldSubscription;
    }

    newSubscriptions[index] = subscription;
    _subscriptions = newSubscriptions;

    // Increment the capturing subscription counter
    // or optimization for broadcast events.

    if (captures) {
      _capturingSubscriptionCount += 1;
    } else {
      switch(this.eventType) {
        case Event.ENTER_FRAME: _enterFrameSubscriptions.add(subscription); break;
        case Event.EXIT_FRAME: _exitFrameSubscriptions.add(subscription); break;
        case Event.RENDER: _renderSubscriptions.add(subscription); break;
      }
    }

    return subscription;
  }

  //----------------------------------------------------------------------------

  _unsubscribe(EventListener eventListener, bool captures) {

    var subscriptions = _subscriptions;

    for(int i = 0; i < subscriptions.length; i++) {
      var subscription = subscriptions[i];
      if (subscription.eventListener == eventListener && subscription.isCapturing == captures) {
        _cancelSubscription(subscription);
      }
    }
  }

  //----------------------------------------------------------------------------

  _cancelSubscription(EventStreamSubscription eventStreamSubscription) {

    eventStreamSubscription._canceled = true;

    var oldSubscriptions = _subscriptions;
    if (oldSubscriptions.length == 0) return;

    var newSubscriptions = new List(oldSubscriptions.length - 1);

    for(int o = 0, n = 0; o < oldSubscriptions.length; o++) {
      var oldSubscription = oldSubscriptions[o];
      if (identical(oldSubscription, eventStreamSubscription)) continue;
      if (n >= newSubscriptions.length) return;
      newSubscriptions[n++] = oldSubscription;
    }

    if (eventStreamSubscription.isCapturing) {
      _capturingSubscriptionCount -= 1;
    }

    _subscriptions = newSubscriptions;
  }

  //----------------------------------------------------------------------------

  _dispatchEventInternal(T event, EventDispatcher target, EventPhase eventPhase)  {

    var subscriptions = _subscriptions;
    var isCapturing = eventPhase == EventPhase.CAPTURING_PHASE;
    var inputEvent = event is InputEvent ? event : null;

    for(var i = 0; i < subscriptions.length; i++) {

      var subscription = subscriptions[i];
      if (subscription.isCanceled || subscription.isPaused ||
          subscription.isCapturing != isCapturing) continue;

      event._target = target;
      event._currentTarget = this.target;
      event._eventPhase = eventPhase;

      InputEvent.current = inputEvent;
      subscription.eventListener(event);
      InputEvent.current = null;

      if (event.isImmediatePropagationStopped) return;
    }
  }

}
