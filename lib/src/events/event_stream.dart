part of stagexl;

class EventStream<T extends Event> extends Stream<T> {

  final EventDispatcher _target;
  final String _eventType;

  // We store the subscriptions in a immutable fixed length list.
  // If subscriptions are added or canceled we create a new list.
  // This is safe and gives good performance in JavaScript.

  List<EventStreamSubscription> _subscriptions = new List(0);
  int _capturingSubscriptionCount = 0;

  EventStream._internal(this._target, this._eventType);

  //-----------------------------------------------------------------------------------------------

  bool get isBroadcast => true;

  Stream<T> asBroadcastStream({
    void onListen(StreamSubscription subscription),
    void onCancel(StreamSubscription subscription)}) => this;

  bool get hasSubscriptions => _subscriptions.length > 0;

  EventDispatcher get target => _target;
  String get eventType => _eventType;

  //-----------------------------------------------------------------------------------------------

  EventStreamSubscription<T> listen(void onData(T event), { Function onError, void onDone(),
    bool cancelOnError: false, int priority: 0 }) {

    return _subscribe(onData, false, priority);
  }

  //-----------------------------------------------------------------------------------------------

  EventStreamSubscription<T> capture(void onData(T event), { int priority: 0 }) {

    return _subscribe(onData, true, priority);
  }

  //-----------------------------------------------------------------------------------------------

  void cancelSubscriptions() {

    var subscriptions = _subscriptions;

    for(int i = 0; i < subscriptions.length; i++) {
      _cancelSubscription(subscriptions[i]);
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  EventStreamSubscription<T> _subscribe(EventListener eventListener, bool captures, int priority) {

    var subscription = new EventStreamSubscription<T>._internal(
        this, eventListener, captures, priority);

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
      switch(_eventType) {
        case Event.ENTER_FRAME: _enterFrameSubscriptions.add(subscription); break;
        case Event.EXIT_FRAME: _exitFrameSubscriptions.add(subscription); break;
        case Event.RENDER: _renderSubscriptions.add(subscription); break;
      }
    }

    return subscription;
  }

  //-----------------------------------------------------------------------------------------------

  _unsubscribe(EventListener eventListener, bool captures) {

    var subscriptions = _subscriptions;

    for(int i = 0; i < subscriptions.length; i++) {
      var subscription = subscriptions[i];
      if (subscription.eventListener == eventListener && subscription.isCapturing == captures) {
        _cancelSubscription(subscription);
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

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

  //-----------------------------------------------------------------------------------------------

  bool _hasPropagationSubscriptions(Event event) {

    return event.captures && _capturingSubscriptionCount > 0 ||
           event.bubbles && _subscriptions.length > _capturingSubscriptionCount;
  }

  //-----------------------------------------------------------------------------------------------

  _dispatchEventInternal(T event, EventDispatcher target, int eventPhase)  {

    var subscriptions = _subscriptions;

    for(var i = 0; i < subscriptions.length; i++) {
      var subscription = subscriptions[i];
      if (subscription.isCanceled || subscription.isPaused ||
          subscription.isCapturing != (eventPhase == EventPhase.CAPTURING_PHASE)) continue;

      event._target = target;
      event._currentTarget = _target;
      event._eventPhase = eventPhase;
      subscription.eventListener(event);

      if (event.stopsImmediatePropagation) return;
    }
  }

}
