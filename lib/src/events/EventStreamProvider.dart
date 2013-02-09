part of dartflash;

class EventStreamProvider<T extends Event> 
{
  final String _eventType;

  const EventStreamProvider(this._eventType);

  Stream<T> forTarget(EventDispatcher target, {bool useCapture: false}) 
  {
    return new _EventStream(target, _eventType, useCapture);
  }

  String get eventType => _eventType;
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _EventStream<T extends Event> extends Stream<T> 
{
  final EventDispatcher _target;
  final String _eventType;
  final bool _useCapture;

  _EventStream(this._target, this._eventType, this._useCapture);

  bool get isBroadcast => true;
  Stream<T> asBroadcastStream() => this;

  StreamSubscription<T> listen(void onData(T event), {void onError(AsyncError error), void onDone(), bool unsubscribeOnError}) 
  {
    return new _EventStreamSubscription<T>(this._target, this._eventType, onData, this._useCapture);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _EventStreamSubscription<T extends Event> extends StreamSubscription<T> 
{
  final String _eventType;
  final bool _useCapture;
  
  EventDispatcher _target;
  EventListener _onData;
  int _pauseCount;

  _EventStreamSubscription(this._target, this._eventType, this._onData, this._useCapture) 
  {
    _pauseCount = 0;
    _tryResume();
  }

  //-----------------------------------------------------------------------------------------------
  
  void cancel() 
  {
    _unlisten();
    _target = null;
    _onData = null;
  }

  bool get _canceled => _target == null;

  //-----------------------------------------------------------------------------------------------
  
  void onData(void handleData(T event)) 
  {
    _unlisten();
    _onData = handleData;
    _tryResume();
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
    _unlisten();

    if (resumeSignal != null)
      resumeSignal.whenComplete(resume);
  }

  void resume() 
  {
    if (_paused == false)
      throw new StateError("Subscription is not paused.");
    
    _pauseCount--;
    _tryResume();
  }

  //-----------------------------------------------------------------------------------------------
  
  void _tryResume() 
  {
    if (_onData != null && _paused == false)
      _target.addEventListener(_eventType, _onData, useCapture: _useCapture);
  }

  void _unlisten() 
  {
    if (_onData != null)
      _target.removeEventListener(_eventType, _onData, useCapture: _useCapture);
  }
  
}
