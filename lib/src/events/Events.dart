class Events
{
  EventDispatcher target;
  Events(EventDispatcher target) : this.target = target;

  EventListenerList operator [](String eventType) => target.getEventListenerList(eventType);
}
