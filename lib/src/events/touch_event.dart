part of stagexl.events;

/// The [TouchEvent] class lets you handle events on devices that detect user
/// contact with the device (such as a finger on a touch screen).
///
/// Use the Multitouch class to determine the current environment's support for
/// touch interaction, and to manage the support of touch interaction if the
/// current environment supports it.

class TouchEvent extends InputEvent {

  static const String TOUCH_BEGIN = "touchBegin";
  static const String TOUCH_END = "touchEnd";
  static const String TOUCH_CANCEL = "touchCancel";
  static const String TOUCH_MOVE = "touchMove";

  static const String TOUCH_OVER = "touchOver";
  static const String TOUCH_OUT = "touchOut";

  static const String TOUCH_ROLL_OUT = "touchRollOut";
  static const String TOUCH_ROLL_OVER  = "touchRollOver";
  static const String TOUCH_TAP  = "touchTap";

  //---------------------------------------------------------------------------

  /// A unique identification number assigned to the touch point.

  final int touchPointID;

  /// Indicates whether the first point of contact is mapped to mouse events.

  final bool isPrimaryTouchPoint;

  /// Creates a new [TouchEvent].

  TouchEvent(
      String type, bool bubbles,
      num localX, num localY, num stageX, num stageY,
      bool altKey, bool ctrlKey, bool shiftKey,
      this.touchPointID, this.isPrimaryTouchPoint) : super(
          type, bubbles, localX, localY, stageX, stageY,
          altKey, ctrlKey, shiftKey);
}
