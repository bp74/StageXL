class EventDispatcher
{
  Map<String, List<_EventListener>> _eventListenersMap;
  
  EventDispatcher();
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  bool hasEventListener(String type)
  { 
    return _eventListenersMap != null && _eventListenersMap.containsKey(type);
  }

  //-------------------------------------------------------------------------------------------------

  void addEventListener(String type, Function listener, [bool useCapture = false])
  {
    _EventListener eventListener = new _EventListener(listener, useCapture);
    
    if (_eventListenersMap == null)
      _eventListenersMap = new Map<String, List<_EventListener>>();

    List<_EventListener> eventListeners = _eventListenersMap[type];

    if (eventListeners == null) 
      eventListeners = new List<_EventListener>();
    else
      eventListeners = new List<_EventListener>.from(eventListeners);
      
    eventListeners.add(eventListener);
    
    _eventListenersMap[type] = eventListeners;
    
    _EventDispatcherCatalog.addEventDispatcher(type, this);
  }

  //-------------------------------------------------------------------------------------------------

  void removeEventListener(String type, Function listener, [bool useCapture = false])
  {
    if (_eventListenersMap != null)
    {
      List<_EventListener> eventListeners = _eventListenersMap[type];

      if (eventListeners != null)
      {
        eventListeners = eventListeners.filter((el) => el.listener == listener && el.useCapture == useCapture); 

        if (eventListeners.length == 0)
          _eventListenersMap.remove(type);
        else
          _eventListenersMap[type] = eventListeners;
        
        _EventDispatcherCatalog.removeEventDispatcher(type, this);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    _invokeEventListeners(event, this, this, EventPhase.AT_TARGET);
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  void _invokeEventListeners(Event event, EventDispatcher target, EventDispatcher currentTarget, int eventPhase)
  {
    if (_eventListenersMap != null)
    {
      List<_EventListener> eventListeners = _eventListenersMap[event.type];

      if (eventListeners != null)
      {
        for(var eventListener in eventListeners)
        {
          if (eventPhase == EventPhase.CAPTURING_PHASE && eventListener.useCapture == false)
            continue;
          
          event._target = target;
          event._currentTarget = currentTarget;
          event._eventPhase = eventPhase;
          
          eventListener.listener(event);
           
          if (event.stopsImmediatePropagation) 
            break;
        }
      }
    }
  }

  
}
