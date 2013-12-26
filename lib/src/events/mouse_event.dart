part of stagexl;

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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num _localX = 0.0, _localY = 0.0;
  num _stageX = 0.0, _stageY = 0.0;
  num _deltaX = 0.0, _deltaY = 0.0;

  bool _buttonDown = false;
  bool _altKey = false;
  bool _controlKey = false;
  bool _ctrlKey = false;
  bool _shiftKey = false;

  int _clickCount = 0;

  MouseEvent(String type, [bool bubbles = false]) : super(type, bubbles);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  set _localPoint(Point point) {
    _localX = point.x;
    _localY = point.y;
  }

  set _stagePoint(Point point) {
    _stageX = point.x;
    _stageY = point.y;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get localX => _localX;
  num get localY => _localY;
  num get stageX => _stageX;
  num get stageY => _stageY;
  num get deltaX => _deltaX;
  num get deltaY => _deltaY;

  bool get buttonDown => _buttonDown;
  bool get altKey => _altKey;
  bool get controlKey => _controlKey;
  bool get ctrlKey => _ctrlKey;
  bool get shiftKey => _shiftKey;

  int get clickCount => _clickCount;
}
