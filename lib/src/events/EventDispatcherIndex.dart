part of dartflash;

class _EventDispatcherIndex
{
  static const enterFrame = const _EventDispatcherIndex();

  final List<EventDispatcher> _eventDispatchers = new List<EventDispatcher>();
  
  const _EventDispatcherIndex();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void update(EventDispatcher eventDispatcher, EventListenerList eventListenerList)
  {
    int index = _eventDispatchers.indexOf(eventDispatcher);
    
    if (eventListenerList.length == 0) {
      if (index != -1) _eventDispatchers.removeAt(index);
    } else {
      if (index == -1) _eventDispatchers.add(eventDispatcher);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    // ToDo: reapply optimizations
    
    var eventDispatchers = new List<EventDispatcher>.from(_eventDispatchers);
    
    for(var eventDispatch in eventDispatchers)
      eventDispatch.dispatchEvent(event);
    
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