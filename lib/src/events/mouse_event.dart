part of stagexl.events;

class MouseEvent extends Event {

  static const String CLICK = "click";
  static const String DOUBLE_CLICK = "doubleClick";

  static const String MOUSE_DOWN = "mouseDown";
  static const String MOUSE_UP = "mouseUp";
  static const String MOUSE_MOVE = "mouseMove";
  static const String MOUSE_OUT = "mouseOut";
  static const String MOUSE_OVER = "mouseOver";
  static const String MOUSE_WHEEL = "mouseWheel";

  static const String MIDDLE_CLICK = "middleClick";
  static const String MIDDLE_MOUSE_DOWN = "middleMouseDown";
  static const String MIDDLE_MOUSE_UP = "middleMouseUp";
  static const String RIGHT_CLICK = "rightClick";
  static const String RIGHT_MOUSE_DOWN = "rightMouseDown";
  static const String RIGHT_MOUSE_UP = "rightMouseUp";

  static const String CONTEXT_MENU = "contextMenu";
  static const String ROLL_OUT = "rollOut";
  static const String ROLL_OVER = "rollOver";

  //-----------------------------------------------------------------------------------------------

  final num localX, localY;
  final num stageX, stageY;
  final num deltaX, deltaY;
  final bool buttonDown;
  final int clickCount;
  final bool altKey, ctrlKey, shiftKey;

  MouseEvent(String type, bool bubbles,
      this.localX, this.localY,
      this.stageX, this.stageY,
      this.deltaX, this.deltaY,
      this.buttonDown, this.clickCount,
      this.altKey, this.ctrlKey, this.shiftKey) : super(type, bubbles);

}
