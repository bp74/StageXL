part of dartflash;

class EventDispatcher
{
  Map<String, _EventStream> _eventStreams;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool hasEventListener(String type)
  {
    if (_eventStreams != null )
      return _eventStreams.containsKey(type) || _eventStreams.containsKey("${type}_CAPTURE");
    else
      return false;
  }

  StreamSubscription<Event> addEventListener(String eventType, void eventListener(event), {bool useCapture: false})
  {
    var eventStream = _getEventStream(eventType, useCapture);
    var eventStreamSubscription = eventStream.listen(eventListener);
    return eventStreamSubscription;
  }
  
  void removeEventListeners(String eventType, {bool useCapture: false})
  {
    var eventStreamKey = useCapture ? "${eventType}_CAPTURE": eventType;
    var eventStream = _eventStreams[eventStreamKey];
    
    if (eventStream != null)
      eventStream._cancelSubscriptions();
  }

  void dispatchEvent(Event event)
  {
    _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);
  }

  //-------------------------------------------------------------------------------------------------
  
  Stream<Event> on(String eventType, {bool useCapture: false}) 
  {
    var eventStream = _getEventStream(eventType, useCapture);
    return eventStream;
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _dispatchEventInternal(Event event, EventDispatcher target, EventDispatcher currentTarget, int eventPhase)
  {
    if (_eventStreams != null) {
      
      var eventStreamKey = (eventPhase == EventPhase.CAPTURING_PHASE) ? "${event.type}_CAPTURE" : event.type;
      var eventStream = _eventStreams[eventStreamKey];
    
      if (eventStream != null) {
        event._target = target;
        event._currentTarget = currentTarget;
        event._eventPhase = eventPhase;
        event._stopsPropagation = false;
        event._stopsImmediatePropagation = false;
      
        eventStream._dispatchEvent(event);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  _EventStream _getEventStream(String eventType, bool useCapture)
  {
    if (_eventStreams == null)
      _eventStreams = new Map<String, _EventStream>();

    var eventStreamKey = useCapture ? "${eventType}_CAPTURE": eventType;
    var eventStream = _eventStreams[eventStreamKey];

    if (eventStream == null)
      eventStream = _eventStreams[eventStreamKey] = new _EventStream(this, eventType, useCapture);

    return eventStream;
  }

}
