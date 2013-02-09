part of dartflash;

class _EventStreamIndex<T extends Event>
{
  static _EventStreamIndex<EnterFrameEvent> enterFrame = new _EventStreamIndex<EnterFrameEvent>();

  List<_EventStream> _eventStreams;
  int _eventStreamsCount;
  
  _EventStreamIndex()
  {
    _eventStreams = new List<_EventStream>(50);
    _eventStreamsCount = 0;
  }

  //-----------------------------------------------------------------------------------------------
  
  void _addEventStream(_EventStream eventStream) {

    for(int i = 0; i < _eventStreamsCount; i++)
      if (_eventStreams[i] == eventStream)
        return;
     
    if (_eventStreamsCount == _eventStreams.length)
      _eventStreams.add(eventStream);
    else
      _eventStreams[_eventStreamsCount] = eventStream;
    
    _eventStreamsCount++;
  }

  //-----------------------------------------------------------------------------------------------
  
  void _dispatchEvent(Event event) {
   
    int eventStreamsCount = _eventStreamsCount;
    int tail = 0;

    event._eventPhase = EventPhase.AT_TARGET;
    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;
    
    for(int head = 0; head < eventStreamsCount; head++) {

      var eventStream = _eventStreams[head];
      if (eventStream != null && eventStream._subscriptionsCount > 0) {
        
        event._target = eventStream._target;
        event._currentTarget = eventStream._target;
        eventStream._dispatchEvent(event);
        
        if (tail != head) _eventStreams[tail] = eventStream;
        tail++;
      }
    }

    for(int i = eventStreamsCount; i < _eventStreamsCount; i++)
      _eventStreams[tail++] = _eventStreams[i];

    for(int i = tail; i < _eventStreamsCount; i++)
      _eventStreams[i] = null;

    _eventStreamsCount = tail;
  }
  
}


