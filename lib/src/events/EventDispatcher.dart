part of dartflash;

class EventDispatcher
{
  Map<String, EventListenerList> _eventListenerLists;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool hasEventListener(String type)
  {
    if (_eventListenerLists != null )
      return _eventListenerLists.containsKey(type) || _eventListenerLists.containsKey("${type}_CAPTURE");
    else
      return false;
  }

  void addEventListener(String type, EventListener eventListener, {bool useCapture: false})
  {
    var eventListenerList = _getEventListenerList(type, useCapture);
    eventListenerList.add(eventListener);
    
    if (type == Event.ENTER_FRAME && useCapture == false)
      _EventDispatcherIndex.enterFrame.update(this, eventListenerList);
  }

  void removeEventListener(String type, EventListener eventListener, {bool useCapture: false})
  {
    var eventListenerList = _getEventListenerList(type, useCapture);
    eventListenerList.remove(eventListener);
    
    if (type == Event.ENTER_FRAME && useCapture == false)
      _EventDispatcherIndex.enterFrame.update(this, eventListenerList);    
  }

  void dispatchEvent(Event event)
  {
    _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);
  }

  //-------------------------------------------------------------------------------------------------
  
  Stream<Event> on(String eventType, {bool useCapture: false}) 
  {
    return new _EventStream(this, eventType, useCapture);
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _dispatchEventInternal(Event event, EventDispatcher target, EventDispatcher currentTarget, int eventPhase)
  {
    if (_eventListenerLists != null)
    {
      var eventListenerListKey = (event.eventPhase == EventPhase.CAPTURING_PHASE) ? "${event.type}_CAPTURE" : event.type;
      var eventListenerList = _eventListenerLists[eventListenerListKey];

      if (eventListenerList != null)
      {
        event._target = target;
        event._currentTarget = currentTarget;
        event._eventPhase = eventPhase;
        event._stopsPropagation = false;
        event._stopsImmediatePropagation = false;

        eventListenerList.dispatchEvent(event);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  EventListenerList _getEventListenerList(String type, bool useCapture)
  {
    if (_eventListenerLists == null)
      _eventListenerLists = new Map<String, EventListenerList>();

    var eventListenerListKey = useCapture ? "${type}_CAPTURE": type;
    var eventListenerList = _eventListenerLists[eventListenerListKey];

    if (eventListenerList == null)
      eventListenerList = _eventListenerLists[eventListenerListKey] = new EventListenerList(type, useCapture);

    return eventListenerList;
  }

}
