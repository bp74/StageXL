part of stagexl;

abstract class InteractiveObject extends DisplayObject {
  
  bool doubleClickEnabled = false;
  bool mouseEnabled = true;
  bool tabEnabled = true;
  int tabIndex = 0;
  
  // mouse events
  
  static const EventStreamProvider<MouseEvent> mouseOutEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OUT);
  static const EventStreamProvider<MouseEvent> mouseOverEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OVER);
  static const EventStreamProvider<MouseEvent> mouseMoveEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_MOVE);
  static const EventStreamProvider<MouseEvent> mouseDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.CLICK);
  static const EventStreamProvider<MouseEvent> mouseDoubleClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.DOUBLE_CLICK);
  static const EventStreamProvider<MouseEvent> mouseMiddleDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseMiddleUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseMiddleClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MIDDLE_CLICK);
  static const EventStreamProvider<MouseEvent> mouseRightDownEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_MOUSE_DOWN);
  static const EventStreamProvider<MouseEvent> mouseRightUpEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_MOUSE_UP);
  static const EventStreamProvider<MouseEvent> mouseRightClickEvent = const EventStreamProvider<MouseEvent>(MouseEvent.RIGHT_CLICK);
  static const EventStreamProvider<MouseEvent> mouseWheelEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_WHEEL);

  Stream<MouseEvent> get onMouseOut => InteractiveObject.mouseOutEvent.forTarget(this);
  Stream<MouseEvent> get onMouseOver => InteractiveObject.mouseOverEvent.forTarget(this);
  Stream<MouseEvent> get onMouseMove => InteractiveObject.mouseMoveEvent.forTarget(this);
  Stream<MouseEvent> get onMouseDown => InteractiveObject.mouseDownEvent.forTarget(this);
  Stream<MouseEvent> get onMouseUp => InteractiveObject.mouseUpEvent.forTarget(this);
  Stream<MouseEvent> get onMouseClick => InteractiveObject.mouseClickEvent.forTarget(this);
  Stream<MouseEvent> get onMouseDoubleClick => InteractiveObject.mouseDoubleClickEvent.forTarget(this);
  Stream<MouseEvent> get onMouseMiddleDown => InteractiveObject.mouseMiddleDownEvent.forTarget(this);
  Stream<MouseEvent> get onMouseMiddleUp => InteractiveObject.mouseMiddleUpEvent.forTarget(this);
  Stream<MouseEvent> get onMouseMiddleClick => InteractiveObject.mouseMiddleClickEvent.forTarget(this);
  Stream<MouseEvent> get onMouseRightDown => InteractiveObject.mouseRightDownEvent.forTarget(this);
  Stream<MouseEvent> get onMouseRightUp => InteractiveObject.mouseRightUpEvent.forTarget(this);
  Stream<MouseEvent> get onMouseRightClick => InteractiveObject.mouseRightClickEvent.forTarget(this);
  Stream<MouseEvent> get onMouseWheel => InteractiveObject.mouseWheelEvent.forTarget(this);
  
  // touch events

  static const EventStreamProvider<TouchEvent> touchOutEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OUT);
  static const EventStreamProvider<TouchEvent> touchOverEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OVER);
  static const EventStreamProvider<TouchEvent> touchMoveEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_MOVE);
  static const EventStreamProvider<TouchEvent> touchBeginEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_BEGIN);
  static const EventStreamProvider<TouchEvent> touchEndEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_END);
  static const EventStreamProvider<TouchEvent> touchCancelEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_CANCEL);
  
  Stream<TouchEvent> get onTouchOut => InteractiveObject.touchOutEvent.forTarget(this);
  Stream<TouchEvent> get onTouchOver => InteractiveObject.touchOverEvent.forTarget(this);
  Stream<TouchEvent> get onTouchMove => InteractiveObject.touchMoveEvent.forTarget(this);
  Stream<TouchEvent> get onTouchBegin => InteractiveObject.touchBeginEvent.forTarget(this);
  Stream<TouchEvent> get onTouchEnd => InteractiveObject.touchEndEvent.forTarget(this);
  Stream<TouchEvent> get onTouchCancel => InteractiveObject.touchCancelEvent.forTarget(this);
  
  // keyboard events

  static const EventStreamProvider<KeyboardEvent> keyUpEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_UP);
  static const EventStreamProvider<KeyboardEvent> keyDownEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_DOWN);

  Stream<KeyboardEvent> get onKeyUp => InteractiveObject.keyUpEvent.forTarget(this);
  Stream<KeyboardEvent> get onKeyDown => InteractiveObject.keyDownEvent.forTarget(this);
  
  // text events

  static const EventStreamProvider<TextEvent> textInputEvent = const EventStreamProvider<TextEvent>(TextEvent.TEXT_INPUT);
  
  Stream<TextEvent> get onTextInput => InteractiveObject.textInputEvent.forTarget(this);
}
