class MouseEvent extends Event
{
  static final String CLICK = "click";
  static final String DOUBLE_CLICK = "doubleClick";
  
  static final String MOUSE_DOWN = "mouseDown";
  static final String MOUSE_UP = "mouseUp";
  static final String MOUSE_MOVE = "mouseMove";
  static final String MOUSE_OUT = "mouseOut";       
  static final String MOUSE_OVER = "mouseOver";     
  static final String MOUSE_WHEEL = "mouseWheel";

  static final String MIDDLE_CLICK = "middleClick";
  static final String MIDDLE_MOUSE_DOWN = "middleMouseDown";
  static final String MIDDLE_MOUSE_UP = "middleMouseUp";
  static final String RIGHT_CLICK = "rightClick";
  static final String RIGHT_MOUSE_DOWN = "rightMouseDown";
  static final String RIGHT_MOUSE_UP = "rightMouseUp";

  static final String CONTEXT_MENU = "contextMenu"; // ToDo
  static final String ROLL_OUT = "rollOut";         // ToDo
  static final String ROLL_OVER = "rollOver";       // ToDo
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  num _localX = 0;
  num _localY = 0;
  num _stageX = 0;
  num _stageY = 0;
  bool _buttonDown = false;
  
  bool _altKey = false;
  bool _controlKey = false;
  bool _ctrlKey = false;
  bool _shiftKey = false;
  
  int _clickCount = 0;
  int _delta = 0;
   
  bool _isRelatedObjectInaccessible = false;
  InteractiveObject _relatedObject = null;
  
  MouseEvent(String type, [bool bubbles = false]):super(type, bubbles)
  {
    
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  num get localX() => _localX; 
  num get localY() => _localY;
  num get stageX() => _stageX;
  num get stageY() => _stageY;
  bool get buttonDown() => _buttonDown;
  
  bool get altKey() => _altKey;
  bool get controlKey() => _controlKey;
  bool get ctrlKey() => _ctrlKey;
  bool get shiftKey() => _shiftKey;
  
  int get clickCount() => _clickCount;
  int get delta() => _delta;
   
  bool get isRelatedObjectInaccessible() => _isRelatedObjectInaccessible;
  InteractiveObject get relatedObject() => _relatedObject;
  
}
