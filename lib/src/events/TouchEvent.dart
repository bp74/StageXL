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

  int _touchPointID;
  bool _isPrimaryTouchPoint;

  num _localX, _localY;
  num _stageX, _stageY;

  bool _altKey;
  bool _controlKey;
  bool _ctrlKey;
  bool _shiftKey;

  num _pressure;
  int _sizeX;
  int _sizeY;

  TouchEvent(String type, [bool bubbles = false]):super(type, bubbles) {
    
    _reset(type, bubbles);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _reset(String type, [bool bubbles = false]) {
    
    super._reset(type, bubbles);

    _touchPointID = 0;
    _isPrimaryTouchPoint = false;

    _localX = _localY = 0;
    _stageX = _stageY = 0;

    _altKey = false;
    _controlKey = false;
    _ctrlKey = false;
    _shiftKey = false;

    _pressure = 1.00;
    _sizeX = 0;
    _sizeY = 0;
  }

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
