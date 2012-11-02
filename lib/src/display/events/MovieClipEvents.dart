part of dartflash;

class MovieClipEvents extends InteractiveObjectEvents {

  MovieClipEvents(EventDispatcher target) : super(target);

  EventListenerList get progress => this[Event.PROGRESS];
  EventListenerList get complete => this[Event.COMPLETE];
}
