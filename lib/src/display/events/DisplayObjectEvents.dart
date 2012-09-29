
class DisplayObjectEvents
{
  EventDispatcher target;
  DisplayObjectEvents(EventDispatcher target) : this.target = target;

  EventListenerList get enterFrame() => target.getEventListenerList(Event.ENTER_FRAME);
}
