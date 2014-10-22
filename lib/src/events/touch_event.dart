part of stagexl.events;

/// The [TouchEvent] class lets you handle events on devices that detect user 
/// contact with the device (such as a finger on a touch screen).
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

  /// A unique identification number assigned to the touch point.
  final int touchPointID;
  
  /// Indicates whether the first point of contact is mapped to mouse events.
  final bool isPrimaryTouchPoint;
  
  /// The x-coordinate at which the event occurred relative to the containing 
  /// display object.
  final num localX;
  
  /// The y-coordinate at which the event occurred relative to the containing 
  /// display object.
  final num localY;
  
  /// The x-coordinate at which the event occurred relative to the stage.
  final num stageX;
  
  /// The y-coordinate at which the event occurred relative to the stage.
  final num stageY;
  
  /// Indicates whether the Alt key is active (true) or inactive (false).
  final bool altKey;
  
  /// Indicates whether the Ctrl key is active (true) or inactive (false).
  final bool ctrlKey;
  
  /// Indicates whether the Shift key is active (true) or inactive (false).
  final bool shiftKey;

  /// Creates a new [TouchEvent].
  TouchEvent(String type, bool bubbles,
      this.touchPointID, this.isPrimaryTouchPoint,
      this.localX, this.localY, this.stageX, this.stageY,
      this.altKey, this.ctrlKey, this.shiftKey) : super(type, bubbles);
}
