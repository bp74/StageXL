part of stagexl;

class _EventStream<T extends Event> extends Stream<T> {

  final EventDispatcher _target;
  final String _eventType;
  final bool _useCapture;

  List<_EventStreamSubscription> _subscriptions = [];

  _EventStream(this._target, this._eventType, this._useCapture);

  //-----------------------------------------------------------------------------------------------

  bool get isBroadcast => true;

  Stream<T> asBroadcastStream({
    void onListen(StreamSubscription subscription),
    void onCancel(StreamSubscription subscription)}) => this;

  bool get _hasSubscriptions => _subscriptions.length > 0;

  //-----------------------------------------------------------------------------------------------

  StreamSubscription<T> listen(void onData(T event), {
    void onError(error), void onDone(), bool cancelOnError:false}) {

    var eventStreamSubscription = new _EventStreamSubscription<T>(this, onData);
    _subscriptions.add(eventStreamSubscription);

    if(_useCapture == false) {
      var eventStream = this;
      switch(_eventType) {
        case Event.ENTER_FRAME: _enterFrameEventIndex.addEventStream(eventStream); break;
        case Event.EXIT_FRAME: _exitFrameEventIndex.addEventStream(eventStream); break;
        case Event.RENDER: _renderEventIndex.addEventStream(eventStream); break;
      }
    }

    return eventStreamSubscription;
  }

  //-----------------------------------------------------------------------------------------------

  cancelSubscription(_EventStreamSubscription eventStreamSubscription) {

    if (eventStreamSubscription._canceled) return;

    var subscriptions = [];

    for(var i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];
      if (identical(subscription, eventStreamSubscription)) {
        subscription._canceled = true;
      } else {
        subscriptions.add(subscription);
      }
    }

    _subscriptions = subscriptions;
  }

  //-----------------------------------------------------------------------------------------------

  cancelSubscriptions() {

    for(var i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];
      subscription._canceled = true;
    }

    _subscriptions = [];
  }

  //-----------------------------------------------------------------------------------------------

  dispatchEvent(T event)  {

    // The _subscriptions list will change when a subscription is canceled.
    // The _subscriptions length will change when a subscription is added.
    // Therefore we keep the current list and length in a local variable.

    var subscriptions = _subscriptions;
    var subscriptionsLength = _subscriptions.length;

    for(var i = 0; i < subscriptionsLength; i++) {
      var subscription = subscriptions[i];
      if (subscription._canceled == false) {
        subscription._onData(event);
      }
    }
  }

}
