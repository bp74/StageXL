part of dartflash;

class _EventStream<T extends Event> extends Stream<T> 
{
  final EventDispatcher _target;
  final String _eventType;
  final bool _useCapture;
  
  List<_EventStreamSubscription> _subscriptions; 
  int _subscriptionsCount;
  
  _EventStream(this._target, this._eventType, this._useCapture)
  {
    _subscriptions = new List<_EventStreamSubscription>(5); 
    _subscriptionsCount = 0;
  }

  //-----------------------------------------------------------------------------------------------
  
  bool get isBroadcast => true;
  Stream<T> asBroadcastStream() => this;

  //-----------------------------------------------------------------------------------------------
  
  StreamSubscription<T> listen(void onData(T event), {void onError(AsyncError error), void onDone(), bool unsubscribeOnError}) 
  {
    var subscription = new _EventStreamSubscription<T>(this, onData);
    
    if (_subscriptionsCount == _subscriptions.length)
      _subscriptions.add(subscription);
    else
      _subscriptions[_subscriptionsCount] = subscription;
    
    _subscriptionsCount++;
    
    if (_eventType == Event.ENTER_FRAME && _useCapture == false)
      _EventStreamIndex.enterFrame._addEventStream(this);
    
    return subscription;
  }
  
  //-----------------------------------------------------------------------------------------------
  
  void _cancelSubscription(StreamSubscription subscription)
  {
    for(int i = 0; i < _subscriptionsCount; i++) {
      if (_subscriptions[i] == subscription) {
        _subscriptions[i] = null;
        break;
      }
    }
  }
  
//-----------------------------------------------------------------------------------------------
  
  void _dispatchEvent(T event) 
  {
    int subscriptionsCount = _subscriptionsCount;
    int tail = 0;

    for(int head = 0; head < subscriptionsCount; head++) {

      var subscription = _subscriptions[head];
      if (subscription != null) {

        subscription._onData(event);
        
        if (tail != head) _subscriptions[tail] = subscription;
        tail++;
      }
    }

    for(int i = subscriptionsCount; i < _subscriptionsCount; i++)
      _subscriptions[tail++] = _subscriptions[i];

    for(int i = tail; i < _subscriptionsCount; i++)
      _subscriptions[i] = null;

    _subscriptionsCount = tail;
  }

}
