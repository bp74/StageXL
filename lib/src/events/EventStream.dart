part of stagexl;

class EventStream<T extends Event> extends Stream<T> {

  final EventDispatcher _target;
  final String _eventType;

  List<EventStreamSubscription> _subscriptions = [];
  int _capturingSubscriptionCount = 0;

  EventStream._internal(this._target, this._eventType);

  //-----------------------------------------------------------------------------------------------

  bool get isBroadcast => true;

  Stream<T> asBroadcastStream({
    void onListen(StreamSubscription subscription),
    void onCancel(StreamSubscription subscription)}) => this;

  bool get hasSubscriptions => _subscriptions.length > 0;

  EventDispatcher get target => _target;

  //-----------------------------------------------------------------------------------------------

  EventStreamSubscription<T> listen(void onData(T event), {
    Function onError, void onDone(), bool cancelOnError:false }) {

    var subscription = new EventStreamSubscription<T>._internal(this, onData, false);
    _subscriptions.add(subscription);

    switch(_eventType) {
      case Event.ENTER_FRAME: _enterFrameSubscriptions.add(subscription); break;
      case Event.EXIT_FRAME: _exitFrameSubscriptions.add(subscription); break;
      case Event.RENDER: _renderSubscriptions.add(subscription); break;
    }

    return subscription;
  }

  //-----------------------------------------------------------------------------------------------

  EventStreamSubscription<T> capture(void onData(T event)) {

    var eventStreamSubscription = new EventStreamSubscription<T>._internal(this, onData, true);

    _subscriptions.add(eventStreamSubscription);
    _capturingSubscriptionCount++;

    return eventStreamSubscription;
  }

  //-----------------------------------------------------------------------------------------------

  void cancelSubscriptions() {

    var subscriptions = _subscriptions;

    for(var i = 0; i < subscriptions.length; i++) {
      subscriptions[i].cancel();
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  _onSubscriptionCancel(EventStreamSubscription eventStreamSubscription) {

    var oldSubscriptions = _subscriptions;
    var newSubscriptions = [];

    if (eventStreamSubscription.isCapturing) {
      _capturingSubscriptionCount--;
    }

    for(var i = 0; i < oldSubscriptions.length; i++) {
      var subscription = oldSubscriptions[i];
      if (identical(subscription, eventStreamSubscription) == false) {
        newSubscriptions.add(subscription);
      }
    }

    _subscriptions = newSubscriptions;
  }

  //-----------------------------------------------------------------------------------------------

  bool _hasPropagationSubscriptions(Event event) {

    return
        event.captures && _capturingSubscriptionCount > 0 ||
        event.bubbles && _subscriptions.length > _capturingSubscriptionCount;
  }

  _dispatchEventInternal(T event, EventDispatcher target, int eventPhase)  {

    // The _subscriptions list will change when a subscription is canceled.
    // The _subscriptions length will change when a subscription is added.
    // Therefore we keep the current list and length in a local variable.

    var subscriptions = _subscriptions;
    var length = subscriptions.length;

    for(var i = 0; i < length; i++) {
      subscriptions[i]._dispatchEventInternal(event, target, eventPhase);
      if (event.stopsImmediatePropagation) return;
    }
  }

}
