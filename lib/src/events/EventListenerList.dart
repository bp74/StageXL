part of dartflash;

class EventListenerList
{
  String _eventType;
  bool _useCapture;
  List<EventListener> _eventListeners;

  EventListenerList(String eventType, bool useCapture)
  {
    _eventType = eventType;
    _useCapture = useCapture;
    _eventListeners = new List<EventListener>();
  }

  //-------------------------------------------------------------------------------------------------

  String get eventType => _eventType;
  bool get useCapture => _useCapture;
  int get length => _eventListeners.length;
  
  //-------------------------------------------------------------------------------------------------

  void add(EventListener eventListener)
  {
    if (_eventListeners.contains(eventListener))
      return;
    
    _eventListeners.add(eventListener);
  }

  //-------------------------------------------------------------------------------------------------

  void remove(EventListener eventListener)
  {
    for(int i = 0; i < _eventListeners.length; i++)
    {
      if (_eventListeners[i] == eventListener)
      {
        _eventListeners = new List<EventListener>.from(_eventListeners);
        _eventListeners.removeAt(i);
        break;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void dispatchEvent(Event event)
  {
    var eventListenersLength = _eventListeners.length;
    
    for(int i = 0; i < eventListenersLength; i++)
    {
      _eventListeners[i](event);
      
      if (event.stopsImmediatePropagation)
        break;
    }
  }
}



