
class DisplayObjectContainerEvents extends DisplayObjectEvents
{
  DisplayObjectContainerEvents(EventDispatcher target) : super(target);

  EventListenerList get added() => target.getEventListenerList(Event.ADDED);
  EventListenerList get addedToStage() => target.getEventListenerList(Event.ADDED_TO_STAGE);

  EventListenerList get removed() => target.getEventListenerList(Event.REMOVED);
  EventListenerList get removedFromStage() => target.getEventListenerList(Event.REMOVED_FROM_STAGE);
}
