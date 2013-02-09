part of dartflash;

class EventStreamProvider<T extends Event> 
{
  final String _eventType;

  const EventStreamProvider(this._eventType);

  Stream<T> forTarget(EventDispatcher target, {bool useCapture: false}) 
  {
    return target._getEventStream(_eventType, useCapture);
  }

  String get eventType => _eventType;
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _EventStreamIndex<T extends Event>
{
  static _EventStreamIndex<EnterFrameEvent> enterFrame = new _EventStreamIndex<EnterFrameEvent>();

  List<_EventStream<T>> _eventStreams = new List<_EventStream<T>>();
  
  void _update(_EventStream eventStream)
  {
    int index = _eventStreams.indexOf(eventStream);
    
    if (eventStream.subscriptionCount == 0) {
      if (index != -1) _eventStreams.removeAt(index);
    } else {
      if (index == -1) _eventStreams.add(eventStream);
    }
  }
  
  void _dispatchEvent(T event)
  {
    // ToDo: optimize code
    
    var eventStreams = new List<_EventStream<T>>.from(_eventStreams);
    
    for(var eventStream in eventStreams)
      eventStream._dispatchEvent(event);
        
    /*
    var length = _eventDispatchers.length;
    int c = 0;

    for(int i = 0; i < length; i++)
    {
      var eventDispatcher = _eventDispatchers[i];

      if (eventDispatcher != null)
      {
        eventDispatcher._dispatchEventInternal(event, eventDispatcher, eventDispatcher, EventPhase.AT_TARGET);

        if (c != i) _eventDispatchers[c] = eventDispatcher;
        c++;
      }
    }

    for(int i = length; i < _eventDispatchers.length; i++)
      _eventDispatchers[c++] = _eventDispatchers[i];

    _eventDispatchers.length = c;
    */
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _EventStream<T extends Event> extends Stream<T> 
{
  final EventDispatcher _target;
  final String _eventType;
  final bool _useCapture;
  final List _subscriptions;
  
  _EventStream(this._target, this._eventType, this._useCapture) : _subscriptions = new List();

  bool get isBroadcast => true;
  Stream<T> asBroadcastStream() => this;

  StreamSubscription<T> listen(void onData(T event), {void onError(AsyncError error), void onDone(), bool unsubscribeOnError}) 
  {
    var subscription = new _EventStreamSubscription<T>(this, onData);
    _subscriptions.add(subscription);
    
    if (_eventType == Event.ENTER_FRAME && _useCapture == false)
      _EventStreamIndex.enterFrame._update(this);
    
    return subscription;
  }
  
  void _cancelSubscription(StreamSubscription subscription)
  {
    _subscriptions.remove(subscription);
    
    if (_eventType == Event.ENTER_FRAME && _useCapture == false)
      _EventStreamIndex.enterFrame._update(this);   
  }
  
  StreamSubscription<T> _getSubscription(void onData(T event))
  {
    for(int i = 0; i < _subscriptions.length; i++) {
      var subscription = _subscriptions[i];  
      if (subscription._onData == onData)
        return subscription;
    }
    
    return null;
  }
  
  void _dispatchEvent(T event) 
  {
    // ToDo: optimize code
    
    for(var subscription in _subscriptions.toList())
      if (subscription._paused == false)
        subscription._onData(event);
  }
  
  int get subscriptionCount => _subscriptions.length;
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

typedef void _EventListener<T extends Event>(T event);

class _EventStreamSubscription<T extends Event> extends StreamSubscription<T> 
{
  _EventStream _eventStream;
  _EventListener<T> _onData;
  int _pauseCount;
  bool _canceled;

  _EventStreamSubscription(this._eventStream, this._onData) 
  {
    _pauseCount = 0;
    _canceled = false;
  }

  //-----------------------------------------------------------------------------------------------
  
  void cancel() 
  {
    if (_canceled == false) 
    {
      _eventStream._cancelSubscription(this);
      _canceled = true;
      _onData = null;
    }
  }

  //-----------------------------------------------------------------------------------------------
  
  void onData(void handleData(T event)) 
  {
    _onData = handleData;
  }

  void onError(void handleError(AsyncError error)) 
  {
  }

  void onDone(void handleDone()) 
  {
  }

  //-----------------------------------------------------------------------------------------------
  
  bool get _paused => _pauseCount > 0;

  void pause([Future resumeSignal]) 
  {
    _pauseCount++;

    if (resumeSignal != null)
      resumeSignal.whenComplete(resume);
  }

  void resume() 
  {
    if (_paused == false)
      throw new StateError("Subscription is not paused.");
    
    _pauseCount--;
  }
  
}
