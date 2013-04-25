part of stagexl;

class _EventStream<T extends Event> extends Stream<T> {
  
  final EventDispatcher _target;
  final String _eventType;
  final bool _useCapture;
  final List<_EventStreamSubscription> _subscriptions = new List<_EventStreamSubscription>();
  
  int _subscriptionsCount = 0;
  
  _EventStream(this._target, this._eventType, this._useCapture);

  //-----------------------------------------------------------------------------------------------
  
  bool get isBroadcast => true;
  Stream<T> asBroadcastStream() => this;

  //-----------------------------------------------------------------------------------------------
  
  StreamSubscription<T> listen(void onData(T event), {void onError(error), void onDone(), bool cancelOnError:false}) {

    var subscription = new _EventStreamSubscription<T>(this, onData);
    
    if (_subscriptionsCount == _subscriptions.length) {
      _subscriptions.add(subscription);
    } else {
      _subscriptions[_subscriptionsCount] = subscription;
    }
    
    _subscriptionsCount++;
    
    if(_useCapture == false) {
      switch(_eventType) {
        case Event.ENTER_FRAME: _EventStreamIndex.enterFrame._addEventStream(this); break;
        case Event.EXIT_FRAME: _EventStreamIndex.exitFrame._addEventStream(this); break;
        case Event.RENDER: _EventStreamIndex.render._addEventStream(this); break;
      }
    }
    
    return subscription;
  }
  
  //-----------------------------------------------------------------------------------------------
  
  void _onSubscriptionCancel(StreamSubscription subscription) {
    
    for(int i = 0; i < _subscriptionsCount; i++) {
      if (identical(_subscriptions[i], subscription)) {
        _subscriptions[i] = null;
        break;
      }
    }
  }
  
  //-----------------------------------------------------------------------------------------------
 
  bool get _hasSubscriptions {
    
    for(var i = 0; i < _subscriptionsCount; i++)
      if (_subscriptions[i] != null) 
        return true;
    
    return false;
  }
    
  //-----------------------------------------------------------------------------------------------
  
  void _cancelSubscriptions() {
    
    for(int i = 0; i < _subscriptionsCount; i++) 
      if (_subscriptions[i] != null)
        _subscriptions[i].cancel();
  }
  
  //-----------------------------------------------------------------------------------------------
  
  void _dispatchEvent(T event)  {
    
    // Dispatch event to current subscriptions.
    // Do not dispatch events to newly added subscriptions.
    // Adjust _subscriptions List.
    
    int subscriptionsCount = _subscriptionsCount;
    int tail = 0;
    
    if (subscriptionsCount is! int) throw "dart2js_hint";
    
    for(int head = 0; head < subscriptionsCount; head++) {
      
      var subscription = _subscriptions[head];
      if (subscription == null) continue;
      
      subscription._onData(event);
        
      if (tail != head) {
        _subscriptions[tail] = subscription;
        _subscriptions[head] = null;
      }
      
      tail++;
    }

    if (tail != subscriptionsCount) {

      for(int head = subscriptionsCount; head < _subscriptionsCount; head++) {
        _subscriptions[tail++] = _subscriptions[head];
        _subscriptions[head] = null;
      }
      
      _subscriptionsCount = tail;
    }
  }

}
