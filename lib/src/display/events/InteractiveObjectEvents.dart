
class InteractiveObjectEvents extends DisplayObjectEvents
{
  InteractiveObjectEvents(EventDispatcher target) : super(target);

  EventListenerList get mouseOut() => target.getEventListenerList(MouseEvent.MOUSE_OUT);
  EventListenerList get mouseOver() => target.getEventListenerList(MouseEvent.MOUSE_OVER);
  EventListenerList get mouseMove() => target.getEventListenerList(MouseEvent.MOUSE_MOVE);
  
  EventListenerList get mouseDown() => target.getEventListenerList(MouseEvent.MOUSE_DOWN);
  EventListenerList get mouseUp() => target.getEventListenerList(MouseEvent.MOUSE_UP);
  EventListenerList get mouseClick() => target.getEventListenerList(MouseEvent.CLICK);
  EventListenerList get mouseDoubleClick() => target.getEventListenerList(MouseEvent.DOUBLE_CLICK);

  EventListenerList get mouseMiddleDown() => target.getEventListenerList(MouseEvent.MIDDLE_MOUSE_DOWN);
  EventListenerList get mouseMiddleUp() => target.getEventListenerList(MouseEvent.MIDDLE_MOUSE_UP);
  EventListenerList get mouseMiddleClick() => target.getEventListenerList(MouseEvent.MIDDLE_CLICK);

  EventListenerList get mouseRightDown() => target.getEventListenerList(MouseEvent.RIGHT_MOUSE_DOWN);
  EventListenerList get mouseRightUp() => target.getEventListenerList(MouseEvent.RIGHT_MOUSE_UP);
  EventListenerList get mouseRightClick() => target.getEventListenerList(MouseEvent.RIGHT_CLICK);
  
  EventListenerList get mouseWheel() => target.getEventListenerList(MouseEvent.MOUSE_WHEEL);
}
