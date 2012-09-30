class EventDispatcher
{
  Map<String, EventListenerList> _eventListenerLists;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  EventListenerList getEventListenerList(String type)
  {
    if (_eventListenerLists == null)
      _eventListenerLists = new Map<String, EventListenerList>();

    EventListenerList eventListenerList = _eventListenerLists[type];

    if (eventListenerList == null)
      eventListenerList = _eventListenerLists[type] = new EventListenerList(this, type);

    return eventListenerList;
  }

  //-------------------------------------------------------------------------------------------------

  bool hasEventListener(String type)
  {
    return _eventListenerLists != null && _eventListenerLists.containsKey(type);
  }

  void addEventListener(String type, Function eventListener, [bool useCapture = false])
  {
    this.getEventListenerList(type).add(eventListener, useCapture);
  }

  void removeEventListener(String type, Function eventListener, [bool useCapture = false])
  {
    this.getEventListenerList(type).remove(eventListener, useCapture);
  }

  void dispatchEvent(Event event)
  {
    _dispatchEventInternal(event, this, this, EventPhase.AT_TARGET);
  }

  //-------------------------------------------------------------------------------------------------

  Events get on => new Events(this);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _dispatchEventInternal(Event event, EventDispatcher target, EventDispatcher currentTarget, int eventPhase)
  {
    if (_eventListenerLists != null)
    {
      EventListenerList eventListenerList = _eventListenerLists[event.type];

      if (eventListenerList != null)
      {
        event._target = target;
        event._currentTarget = currentTarget;
        event._eventPhase = eventPhase;

        eventListenerList.dispatchEvent(event);
      }
    }
  }

}
