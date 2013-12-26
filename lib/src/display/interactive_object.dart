part of stagexl;

abstract class InteractiveObject extends DisplayObject {

  bool doubleClickEnabled = false;
  bool mouseEnabled = true;
  bool tabEnabled = true;
  int tabIndex = 0;

  // mouse events

  static const EventStreamProvider<MouseEvent> mouseOutEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OUT);
  static const EventStreamProvider<MouseEvent> mouseOverEvent = const EventStreamProvider<MouseEvent>(MouseEvent.MOUSE_OVER);
  static const EventStreamProvider<MouseEvent> mouseRollOutEvent = const EventStreamProvider<MouseEvent>(MouseEvent.ROLL_OUT);
  static const EventStreamProvider<MouseEvent> mouseRollOverEvent = const EventStreamProvider<MouseEvent>(MouseEvent.ROLL_OVER);
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
  static const EventStreamProvider<MouseEvent> mouseContextMenu = const EventStreamProvider<MouseEvent>(MouseEvent.CONTEXT_MENU);

  EventStream<MouseEvent> get onMouseOut => InteractiveObject.mouseOutEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseOver => InteractiveObject.mouseOverEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseRollOut => InteractiveObject.mouseRollOutEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseRollOver => InteractiveObject.mouseRollOverEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseMove => InteractiveObject.mouseMoveEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseDown => InteractiveObject.mouseDownEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseUp => InteractiveObject.mouseUpEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseClick => InteractiveObject.mouseClickEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseDoubleClick => InteractiveObject.mouseDoubleClickEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseMiddleDown => InteractiveObject.mouseMiddleDownEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseMiddleUp => InteractiveObject.mouseMiddleUpEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseMiddleClick => InteractiveObject.mouseMiddleClickEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseRightDown => InteractiveObject.mouseRightDownEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseRightUp => InteractiveObject.mouseRightUpEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseRightClick => InteractiveObject.mouseRightClickEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseWheel => InteractiveObject.mouseWheelEvent.forTarget(this);
  EventStream<MouseEvent> get onMouseContextMenu => InteractiveObject.mouseContextMenu.forTarget(this);

  // touch events

  static const EventStreamProvider<TouchEvent> touchOutEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OUT);
  static const EventStreamProvider<TouchEvent> touchOverEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_OVER);
  static const EventStreamProvider<TouchEvent> touchMoveEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_MOVE);
  static const EventStreamProvider<TouchEvent> touchBeginEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_BEGIN);
  static const EventStreamProvider<TouchEvent> touchEndEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_END);
  static const EventStreamProvider<TouchEvent> touchCancelEvent = const EventStreamProvider<TouchEvent>(TouchEvent.TOUCH_CANCEL);

  EventStream<TouchEvent> get onTouchOut => InteractiveObject.touchOutEvent.forTarget(this);
  EventStream<TouchEvent> get onTouchOver => InteractiveObject.touchOverEvent.forTarget(this);
  EventStream<TouchEvent> get onTouchMove => InteractiveObject.touchMoveEvent.forTarget(this);
  EventStream<TouchEvent> get onTouchBegin => InteractiveObject.touchBeginEvent.forTarget(this);
  EventStream<TouchEvent> get onTouchEnd => InteractiveObject.touchEndEvent.forTarget(this);
  EventStream<TouchEvent> get onTouchCancel => InteractiveObject.touchCancelEvent.forTarget(this);

  // keyboard events

  static const EventStreamProvider<KeyboardEvent> keyUpEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_UP);
  static const EventStreamProvider<KeyboardEvent> keyDownEvent = const EventStreamProvider<KeyboardEvent>(KeyboardEvent.KEY_DOWN);

  EventStream<KeyboardEvent> get onKeyUp => InteractiveObject.keyUpEvent.forTarget(this);
  EventStream<KeyboardEvent> get onKeyDown => InteractiveObject.keyDownEvent.forTarget(this);

  // text events

  static const EventStreamProvider<TextEvent> textInputEvent = const EventStreamProvider<TextEvent>(TextEvent.TEXT_INPUT);

  EventStream<TextEvent> get onTextInput => InteractiveObject.textInputEvent.forTarget(this);
}
