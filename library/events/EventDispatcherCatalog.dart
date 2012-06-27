class _EventDispatcherCatalog
{
  static Map<String, List<EventDispatcher>> _eventDispatcherMap;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  static void addEventDispatcher(String eventType, EventDispatcher eventDispatcher)
  {
    if (eventType != Event.ENTER_FRAME)
      return;
    
    if (_eventDispatcherMap == null) 
      _eventDispatcherMap = new Map<String, List<EventDispatcher>>();
    
    List<EventDispatcher> eventDispatchers = _eventDispatcherMap[eventType];
    
    if (eventDispatchers == null) 
      _eventDispatcherMap[eventType] = eventDispatchers = new List<EventDispatcher>();
    
    eventDispatchers.add(eventDispatcher);
  }
  
  //-------------------------------------------------------------------------------------------------

  static void removeEventDispatcher(String eventType, EventDispatcher eventDispatcher)
  {
    if (_eventDispatcherMap != null)
    {
      List<EventDispatcher> eventDispatchers = _eventDispatcherMap[eventType];

      if (eventDispatchers != null)
      {
        var index = eventDispatchers.indexOf(eventDispatcher);
      
        if (index != -1)
          eventDispatchers[index] = null;
      }
    }
  }
  
  //-------------------------------------------------------------------------------------------------
  
  static void dispatchEvent(Event event)
  {
    if (_eventDispatcherMap != null)
    {
      List<EventDispatcher> eventDispatchers = _eventDispatcherMap[event.type];
    
      if (eventDispatchers != null)
      {
        int eventDispatchersLength = eventDispatchers.length;
        int c = 0;
    
        for(int i = 0; i < eventDispatchersLength; i++)
        {
          EventDispatcher eventDispatcher = eventDispatchers[i];
          
          if (eventDispatcher != null)
          {
            eventDispatcher.dispatchEvent(event);
            
            if (c != i) 
              eventDispatchers[c] = eventDispatcher;
      
            c++;
          }
        }
    
        for(int i = eventDispatchersLength; i < eventDispatchers.length; i++)
          eventDispatchers[c++] = eventDispatchers[i];
        
        eventDispatchers.length = c;
      }
    }
  }
  
}
