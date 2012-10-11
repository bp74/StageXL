part of dartflash;


class InteractiveObjectEvents extends DisplayObjectEvents
{
  InteractiveObjectEvents(EventDispatcher target) : super(target);

  EventListenerList get mouseOut => this[MouseEvent.MOUSE_OUT];
  EventListenerList get mouseOver => this[MouseEvent.MOUSE_OVER];
  EventListenerList get mouseMove => this[MouseEvent.MOUSE_MOVE];

  EventListenerList get mouseDown => this[MouseEvent.MOUSE_DOWN];
  EventListenerList get mouseUp => this[MouseEvent.MOUSE_UP];
  EventListenerList get mouseClick => this[MouseEvent.CLICK];
  EventListenerList get mouseDoubleClick => this[MouseEvent.DOUBLE_CLICK];

  EventListenerList get mouseMiddleDown => this[MouseEvent.MIDDLE_MOUSE_DOWN];
  EventListenerList get mouseMiddleUp => this[MouseEvent.MIDDLE_MOUSE_UP];
  EventListenerList get mouseMiddleClick => this[MouseEvent.MIDDLE_CLICK];

  EventListenerList get mouseRightDown => this[MouseEvent.RIGHT_MOUSE_DOWN];
  EventListenerList get mouseRightUp => this[MouseEvent.RIGHT_MOUSE_UP];
  EventListenerList get mouseRightClick => this[MouseEvent.RIGHT_CLICK];

  EventListenerList get mouseWheel => this[MouseEvent.MOUSE_WHEEL];
}
