
class DisplayObjectEvents extends Events
{
  DisplayObjectEvents(EventDispatcher target) : super(target);

  EventListenerList get enterFrame => this[Event.ENTER_FRAME];

  EventListenerList get added => this[Event.ADDED];
  EventListenerList get addedToStage => this[Event.ADDED_TO_STAGE];

  EventListenerList get removed => this[Event.REMOVED];
  EventListenerList get removedFromStage => this[Event.REMOVED_FROM_STAGE];
}
