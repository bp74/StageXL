part of dartflash;

class _EventStreamIndex<T extends Event>
{
  final List<_EventStream> _eventStreams;
  int _eventStreamsCount = 0;
  
  _EventStreamIndex():
    _eventStreams = new List<_EventStream>(50);

  //-----------------------------------------------------------------------------------------------

  static _EventStreamIndex<EnterFrameEvent> enterFrame = new _EventStreamIndex<EnterFrameEvent>();
  
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
   
    event._eventPhase = EventPhase.AT_TARGET;
    event._stopsPropagation = false;
    event._stopsImmediatePropagation = false;

    // Dispatch event to current event streams.
    // Do not dispatch events to newly added streams.
    // Adjust _eventStreams List.
    
    int eventStreamsCount = _eventStreamsCount;
    int tail = 0;
    
    for(int head = 0; head < eventStreamsCount; head++) {

      var eventStream = _eventStreams[head];
      if (eventStream == null) continue;

      if (eventStream._subscriptionsCount == 0) {
        _eventStreams[head] = null;
        continue;
      }

      event._target = eventStream._target;
      event._currentTarget = eventStream._target;
      eventStream._dispatchEvent(event);
        
      if (tail != head) {
        _eventStreams[tail] = eventStream;
        _eventStreams[head] = null;
      }
      
      tail++;
    }

    if (tail != eventStreamsCount) {
      
      for(int head = eventStreamsCount; head < _eventStreamsCount; head++) {
        _eventStreams[tail++] = _eventStreams[head];
        _eventStreams[head] = null;
      }
    
      _eventStreamsCount = tail;
    }
  }
  
}


