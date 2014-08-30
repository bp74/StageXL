part of stagexl.events;

class TouchEvent extends Event {

  static const String TOUCH_BEGIN = "touchBegin";
  static const String TOUCH_END = "touchEnd";
  static const String TOUCH_CANCEL = "touchCancel";
  static const String TOUCH_MOVE = "touchMove";

  static const String TOUCH_OVER = "touchOver";
  static const String TOUCH_OUT = "touchOut";

  static const String TOUCH_ROLL_OUT = "touchRollOut";
  static const String TOUCH_ROLL_OVER  = "touchRollOver";
  static const String TOUCH_TAP  = "touchTap";              // ToDo

  //-----------------------------------------------------------------------------------------------

  final int touchPointID;
  final bool isPrimaryTouchPoint;
  final num localX, localY;
  final num stageX, stageY;
  final bool altKey, ctrlKey, shiftKey;

  TouchEvent(String type, bool bubbles,
      this.touchPointID, this.isPrimaryTouchPoint,
      this.localX, this.localY, this.stageX, this.stageY,
      this.altKey, this.ctrlKey, this.shiftKey) : super(type, bubbles);
}
