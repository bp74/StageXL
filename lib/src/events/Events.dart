class Events
{
  EventDispatcher _eventDispatcher;

  Events(EventDispatcher eventDispatcher)
  {
    _eventDispatcher = eventDispatcher;
  }

  EventListenerList operator [](String eventType)
  {
    return _eventDispatcher._getEventListenerList(eventType);
  }
}
