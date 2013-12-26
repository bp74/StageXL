part of stagexl;

class TouchEvent extends Event {

  static const String TOUCH_BEGIN = "touchBegin";
  static const String TOUCH_END = "touchEnd";
  static const String TOUCH_CANCEL = "touchCancel";
  static const String TOUCH_MOVE = "touchMove";

  static const String TOUCH_OVER = "touchOver";
  static const String TOUCH_OUT = "touchOut";

  static const String TOUCH_ROLL_OUT = "touchRollOut";      // ToDo
  static const String TOUCH_ROLL_OVER  = "touchRollOver";   // ToDo
  static const String TOUCH_TAP  = "touchTap";              // ToDo

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int _touchPointID = 0;
  bool _isPrimaryTouchPoint = false;

  num _localX = 0.0, _localY = 0.0;
  num _stageX = 0.0, _stageY = 0.0;

  bool _altKey = false;
  bool _controlKey = false;
  bool _ctrlKey = false;
  bool _shiftKey = false;

  num _pressure = 1.0;
  int _sizeX = 0;
  int _sizeY = 0;

  TouchEvent(String type, [bool bubbles = false]) : super(type, bubbles);

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

  int get touchPointID => _touchPointID;
  bool get isPrimaryTouchPoint => _isPrimaryTouchPoint;

  num get localX => _localX;
  num get localY => _localY;
  num get stageX => _stageX;
  num get stageY => _stageY;

  bool get altKey => _altKey;
  bool get controlKey => _controlKey;
  bool get ctrlKey => _ctrlKey;
  bool get shiftKey => _shiftKey;

  int get pressure => _pressure;
  int get sizeX => _sizeX;
  int get sizeY => _sizeY;
}
