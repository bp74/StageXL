part of stagexl;

class StageScaleMode {
  static const String EXACT_FIT = "exactFit";
  static const String NO_BORDER = "noBorder";
  static const String NO_SCALE = "noScale";
  static const String SHOW_ALL = "showAll";
}

class StageAlign {
  static const String BOTTOM = "B";
  static const String BOTTOM_LEFT = "BL";
  static const String BOTTOM_RIGHT = "BR";
  static const String LEFT = "L";
  static const String RIGHT = "R";
  static const String TOP = "T";
  static const String TOP_LEFT = "TL";
  static const String TOP_RIGHT = "TR";
  static const String NONE = "";
}

class StageRenderMode {
  static const String AUTO = "auto";
  static const String STOP = "stop";
  static const String ONCE = "once";
}

//-------------------------------------------------------------------------------------------------

class _MouseButton {
  InteractiveObject target = null;
  bool buttonDown = false;
  int clickTime = 0;
  int clickCount = 0;
  String mouseDownEventType, mouseUpEventType;
  String mouseClickEventType, mouseDoubleClickEventType;

  _MouseButton(this.mouseDownEventType, this.mouseUpEventType, this.mouseClickEventType, this.mouseDoubleClickEventType);
}

class _Touch {
  static int _globalTouchPointID = 0;

  int touchPointID = _globalTouchPointID++;
  InteractiveObject target = null;
  bool primaryTouchPoint = false;

  _Touch(this.target, this.primaryTouchPoint);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class Stage extends DisplayObjectContainer {
  
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  int _defaultWidth, _defaultHeight;
  int _canvasWidth, _canvasHeight;
  int _clientWidth, _clientHeight;
  Matrix _clientTransformation;
  Matrix _stageTransformation;
  RenderLoop _renderLoop;
  Juggler _juggler;
  
  InteractiveObject _focus;
  RenderState _renderState;
  String _stageRenderMode;
  String _stageScaleMode;  
  String _stageAlign;
  
  String _mouseCursor;
  Point _mousePosition;
  InteractiveObject _mouseTarget;
  List<_MouseButton> _mouseButtons;
  Map<int, _Touch> _touches;

  MouseEvent _mouseEvent;
  KeyboardEvent _keyboardEvent;
  TouchEvent _touchEvent;

  //-------------------------------------------------------------------------------------------------

  Stage(String name, CanvasElement canvas) {

    _name = name;
    _canvas = canvas;
    _canvas.focus();

    _context = canvas.context2d;
    _canvasWidth = _defaultWidth = canvas.width;
    _canvasHeight = _defaultHeight = canvas.height;
    
    _clientWidth = canvas.clientWidth;
    _clientHeight = canvas.clientHeight;
    _clientTransformation = new Matrix.fromIdentity();
    _stageTransformation = new Matrix.fromIdentity();
    _renderLoop = null;
    _juggler = new Juggler();
    
    _renderState = new RenderState.fromCanvasRenderingContext2D(_context);
    _stageRenderMode = StageRenderMode.AUTO;
    _stageScaleMode = StageScaleMode.SHOW_ALL;
    _stageAlign = StageAlign.NONE;
    
    //---------------------------
    // prepare mouse events

    _mouseButtons = [
      new _MouseButton(MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK),
      new _MouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_CLICK),
      new _MouseButton(MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP, MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_CLICK)
    ];

    _mouseCursor = MouseCursor.ARROW;
    _mouseTarget = null;
    _mousePosition = new Point(0, 0);
    _mouseEvent = new MouseEvent(MouseEvent.CLICK, true);

    Mouse._onMouseCursorChanged.listen(_onMouseCursorChanged);

    _canvas.onMouseDown.listen(_onMouseEvent);
    _canvas.onMouseUp.listen(_onMouseEvent);
    _canvas.onMouseMove.listen(_onMouseEvent);
    _canvas.onMouseOut.listen(_onMouseEvent);
    _canvas.onMouseWheel.listen(_onMouseWheelEvent);

    //---------------------------
    // prepare touch events

    _touches = new Map<int, _Touch>();
    _touchEvent = new TouchEvent(TouchEvent.TOUCH_BEGIN, true);

    Multitouch._onInputModeChanged.listen(_onMultitouchInputModeChanged);
    _onMultitouchInputModeChanged(null);

    //---------------------------
    // prepare keyboard events

    _keyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true);

    _canvas.onKeyDown.listen(_onKeyEvent);
    _canvas.onKeyUp.listen(_onKeyEvent);
    _canvas.onKeyPress.listen(_onTextEvent);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
 
  int get stageWidth => _clientWidth;
  int get stageHeight => _clientHeight;
  
  RenderLoop get renderLoop => _renderLoop;
  Juggler get juggler => _juggler;
  
  Point get mousePosition => _mousePosition;
  
  InteractiveObject get focus => _focus;
  set focus(InteractiveObject value) { 
    _focus = value; 
  }

  String get renderMode => _stageRenderMode;
  set renderMode(String value) { 
    _stageRenderMode = value; 
  }

  String get scaleMode => _stageScaleMode;
  set scaleMode(String value) {
    _stageScaleMode = value;
  }
  
  String get align => _stageAlign;
  set align(String value) {
    _stageAlign = value;
  }
 
  //-------------------------------------------------------------------------------------------------

  _throwStageException() {
    throw new UnsupportedError("Error #2071: The Stage class does not implement this property or method.");
  }

  set x(num value) { _throwStageException(); }
  set y(num value) { _throwStageException(); }
  set pivotX(num value) { _throwStageException(); }
  set pivotY(num value) { _throwStageException(); }
  set scaleX(num value) { _throwStageException(); }
  set scaleY(num value) { _throwStageException(); }
  set skewX(num value) { _throwStageException(); }
  set skewY(num value) { _throwStageException(); }
  set rotation(num value) { _throwStageException(); }
  set alpha(num value) { _throwStageException(); }
  set width(num value) { _throwStageException(); }
  set height(num value) { _throwStageException(); }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  materialize() {
    
    if (_stageRenderMode == StageRenderMode.AUTO || _stageRenderMode == StageRenderMode.ONCE) {
      
      _updateCanvasSize();
      
      _renderState.reset(_stageTransformation);
      render(_renderState);

      if (_stageRenderMode == StageRenderMode.ONCE)
        _stageRenderMode = StageRenderMode.STOP;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _updateCanvasSize() {
    
    var client = _canvas.getBoundingClientRect();
    var clientLeft = _canvas.clientLeft + client.left;
    var clientTop = _canvas.clientTop + client.top;
    var clientWidth = _canvas.clientWidth;
    var clientHeight = _canvas.clientHeight;
    
    if (clientWidth == 0 || clientHeight == 0)
      return;
   
    var canvasWidth = _defaultWidth;
    var canvasHeight = _defaultHeight;
    var canvasPivotX = 0;
    var canvasPivotY = 0;
    
    //----------------------------
    
    switch(_stageScaleMode) {
      
      case StageScaleMode.EXACT_FIT:
        canvasWidth = _defaultWidth;
        canvasHeight = _defaultHeight;
        break;
        
      case StageScaleMode.NO_BORDER:
        if (clientWidth * _defaultHeight > clientHeight * _defaultWidth) {
          canvasHeight = (_defaultWidth * clientHeight) ~/ clientWidth;
        } else {
          canvasWidth = (_defaultHeight * clientWidth) ~/ clientHeight;
        }
        break;
        
      case StageScaleMode.NO_SCALE: 
        canvasWidth = clientWidth;
        canvasHeight = clientHeight;
        break;
        
      case StageScaleMode.SHOW_ALL: 
        if (clientWidth * _defaultHeight > clientHeight * _defaultWidth) {
          canvasWidth = (_defaultHeight * clientWidth) ~/ clientHeight;
        } else {
          canvasHeight = (_defaultWidth * clientHeight) ~/ clientWidth;
        }
        break;
    }
    
    //----------------------------
    
    switch(_stageAlign) {
      case StageAlign.BOTTOM:
        canvasPivotX = (_defaultWidth - canvasWidth + 1) ~/ 2;
        canvasPivotY = (_defaultHeight - canvasHeight);
        break;
      case StageAlign.BOTTOM_LEFT:
        canvasPivotX = 0;
        canvasPivotY = (_defaultHeight - canvasHeight);
        break;
      case StageAlign.BOTTOM_RIGHT:
        canvasPivotX = (_defaultWidth - canvasWidth);
        canvasPivotY = (_defaultHeight - canvasHeight);
        break;
      case StageAlign.LEFT:
        canvasPivotX = 0;
        canvasPivotY = (_defaultHeight - canvasHeight + 1) ~/ 2;
        break;
      case StageAlign.RIGHT:
        canvasPivotX = (_defaultWidth - canvasWidth);
        canvasPivotY = (_defaultHeight - canvasHeight + 1) ~/ 2;
        break;
      case StageAlign.TOP:
        canvasPivotX = (_defaultWidth - canvasWidth + 1) ~/ 2;
        canvasPivotY = 0;
        break;
      case StageAlign.TOP_LEFT:
        canvasPivotX = 0;
        canvasPivotY = 0;
        break;
      case StageAlign.TOP_RIGHT:
        canvasPivotX = (_defaultWidth - canvasWidth + 1);
        canvasPivotY = 0;
        break;
      case StageAlign.NONE:
        canvasPivotX = (_defaultWidth - canvasWidth + 1) ~/ 2;
        canvasPivotY = (_defaultHeight - canvasHeight + 1) ~/ 2;
        break;
    }
    
    //----------------------------

    // stage to canvas coordinate transformation    
    _stageTransformation.setTo(1.0, 0.0, 0.0, 1.0, 0 - canvasPivotX, 0 - canvasPivotY);
    
    // client to stage coordinate transformation
    _clientTransformation.setTo(
        canvasWidth / clientWidth, 0.0, 0.0, canvasHeight / clientHeight,
        canvasPivotX - clientLeft , canvasPivotY - clientTop);

    if (_canvasWidth != canvasWidth || _canvasHeight != canvasHeight) {
      _canvas.width = _canvasWidth = canvasWidth;
      _canvas.height = _canvasHeight = canvasHeight;
    }
    
    if (_clientWidth != clientWidth || _clientHeight != clientHeight) {
      _clientWidth = clientWidth;
      _clientHeight = clientHeight;
      dispatchEvent(new Event(Event.RESIZE));
    }
  }
  
  //-------------------------------------------------------------------------------------------------

  _onMouseCursorChanged(String action) {

    _canvas.style.cursor = Mouse._getCssStyle(_mouseCursor);
  }

  //-------------------------------------------------------------------------------------------------

  _onMouseEvent(html.MouseEvent event) {
    
    event.preventDefault();

    var time = new DateTime.now().millisecondsSinceEpoch;
    var button = event.button;

    InteractiveObject target = null;
    Point stagePoint = _clientTransformation._transformHtmlPoint(event.client);
    Point localPoint = null;

    if (button < 0 || button > 2) return;
    if (event.type == "mousemove" && _mousePosition.equals(stagePoint)) return;

    _MouseButton mouseButton = _mouseButtons[button];
    _mousePosition = stagePoint;

    if (Mouse._dragSprite != null)
      Mouse._dragSprite._updateDrag();
    
    if (event.type != "mouseout")
      target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;

    //-----------------------------------------------------------------

    var mouseCursor = MouseCursor.ARROW;

    if (target is Sprite)
      if (target.useHandCursor)
        mouseCursor = MouseCursor.BUTTON;

    if (target is SimpleButton)
      if (target.useHandCursor)
        mouseCursor = MouseCursor.BUTTON;

    if (_mouseCursor != mouseCursor) {
      _mouseCursor = mouseCursor;
      _canvas.style.cursor = Mouse._getCssStyle(mouseCursor);
    }

    //-----------------------------------------------------------------

    if (_mouseTarget != null && _mouseTarget != target) {

      _mouseTarget.dispatchEvent(_mouseEvent
        .._reset(MouseEvent.MOUSE_OUT, true)
        .._localPoint = (_mouseTarget.stage != null) ? _mouseTarget.globalToLocal(stagePoint) : new Point.zero()
        .._stagePoint = stagePoint
        .._buttonDown = mouseButton.buttonDown);

      _mouseTarget = null;
    }

    if (target != null && target != _mouseTarget) {

      target.dispatchEvent(_mouseEvent
        .._reset(MouseEvent.MOUSE_OVER, true)
        .._localPoint = target.globalToLocal(stagePoint)
        .._stagePoint = stagePoint
        .._buttonDown = mouseButton.buttonDown);

      _mouseTarget = target;
    }

    //-----------------------------------------------------------------

    String mouseEventType = null;
    bool isClick = false;
    bool isDoubleClick = false;

    if (event.type == "mousedown") {
      mouseEventType = mouseButton.mouseDownEventType;

      if (target != mouseButton.target || time > mouseButton.clickTime + 500)
        mouseButton.clickCount = 0;

      mouseButton.buttonDown = true;
      mouseButton.target = target;
      mouseButton.clickTime = time;
      mouseButton.clickCount++;
    }

    if (event.type == "mouseup") {
      mouseEventType = mouseButton.mouseUpEventType;
      mouseButton.buttonDown = false;
      isClick = (mouseButton.target == target);
      isDoubleClick = isClick && mouseButton.clickCount.isEven && (time < mouseButton.clickTime + 500);
    }

    if (event.type == "mousemove") {
      mouseEventType = MouseEvent.MOUSE_MOVE;
    }

    //-----------------------------------------------------------------

    if (mouseEventType != null && target != null) {

      localPoint = target.globalToLocal(stagePoint);

      target.dispatchEvent(_mouseEvent
        .._reset(mouseEventType, true)
        .._localPoint = localPoint
        .._stagePoint = stagePoint
        .._buttonDown = mouseButton.buttonDown
        .._clickCount = mouseButton.clickCount);

      if (isClick) {

        if (isDoubleClick && target.doubleClickEnabled) {

          target.dispatchEvent(_mouseEvent
            .._reset(mouseButton.mouseDoubleClickEventType, true)
            .._localPoint = localPoint
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);

        } else {

          target.dispatchEvent(_mouseEvent
            .._reset(mouseButton.mouseClickEventType, true)
            .._localPoint = localPoint
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);
        }
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onMouseWheelEvent(html.WheelEvent event) {
    
    var stagePoint = _clientTransformation._transformHtmlPoint(event.client);
    var target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;

    if (target != null) {
      target.dispatchEvent(_mouseEvent
        .._reset(MouseEvent.MOUSE_WHEEL, true)
        .._localPoint = target.globalToLocal(stagePoint)
        .._stagePoint = stagePoint
        .._deltaX = event.deltaX
        .._deltaY = event.deltaY);
      
      if (_mouseEvent.stopsPropagation)
        event.preventDefault();
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  List<StreamSubscription<TouchEvent>> _touchEventSubscriptions = [];
  
  _onMultitouchInputModeChanged(String inputMode) {
    
    _touchEventSubscriptions.forEach((s) => s.cancel());
        
    if (Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT) {
      _touchEventSubscriptions = [
        _canvas.onTouchStart.listen(_onTouchEvent),
        _canvas.onTouchEnd.listen(_onTouchEvent),
        _canvas.onTouchMove.listen(_onTouchEvent),
        _canvas.onTouchEnter.listen(_onTouchEvent),
        _canvas.onTouchLeave.listen(_onTouchEvent),
        _canvas.onTouchCancel.listen(_onTouchEvent)
      ];
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onTouchEvent(html.TouchEvent event) {
    
    event.preventDefault();

    for(var changedTouch in event.changedTouches) {

      var identifier = changedTouch.identifier;
      var stagePoint = _clientTransformation._transformHtmlPoint(changedTouch.client);
      var target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;
      var touch = _touches.containsKey(identifier) ? _touches[identifier] : new _Touch(target, _touches.length == 0);

      //-----------------------------------------------------------------

      if (touch.target != null && touch.target != target) {

        touch.target.dispatchEvent(_touchEvent
          .._reset(TouchEvent.TOUCH_OUT, true)
          .._localPoint = (touch.target.stage != null) ? touch.target.globalToLocal(stagePoint): new Point.zero()
          .._stagePoint = stagePoint
          .._touchPointID = touch.touchPointID
          .._isPrimaryTouchPoint = touch.primaryTouchPoint);

        touch.target = null;
      }

      if (target != null && target != touch.target) {

        target.dispatchEvent(_touchEvent
          .._reset(TouchEvent.TOUCH_OVER, true)
          .._localPoint = target.globalToLocal(stagePoint)
          .._stagePoint = stagePoint
          .._touchPointID = touch.touchPointID
          .._isPrimaryTouchPoint = touch.primaryTouchPoint);

        touch.target = target;
      }

      //-----------------------------------------------------------------

      String touchEventType = null;

      if (event.type == "touchstart") {
        _touches[identifier] = touch;
        touchEventType = TouchEvent.TOUCH_BEGIN;
      }

      if (event.type == "touchend") {
        _touches.remove(identifier);
        touchEventType = TouchEvent.TOUCH_END;
      }

      if (event.type == "touchcancel") {
        _touches.remove(identifier);
        touchEventType = TouchEvent.TOUCH_CANCEL;
      }

      if (event.type == "touchmove") {
        touchEventType = TouchEvent.TOUCH_MOVE;
      }

      if (touchEventType != null && target != null) {

        target.dispatchEvent(_touchEvent
          .._reset(touchEventType, true)
          .._localPoint = target.globalToLocal(stagePoint)
          .._stagePoint = stagePoint
          .._touchPointID = touch.touchPointID
          .._isPrimaryTouchPoint = touch.primaryTouchPoint);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _onKeyEvent(html.KeyboardEvent event) {
    
    event.preventDefault();

    String keyboardEventType = null;

    if (event.type == "keyup") keyboardEventType = KeyboardEvent.KEY_UP;
    if (event.type == "keydown") keyboardEventType = KeyboardEvent.KEY_DOWN;

    _keyboardEvent
      .._reset(keyboardEventType, true)
      .._altKey = event.altKey
      .._ctrlKey = event.ctrlKey
      .._shiftKey = event.shiftKey
      .._charCode = event.charCode
      .._keyCode = event.keyCode
      .._keyLocation = KeyLocation.STANDARD;

    if (event.keyLocation == html.KeyLocation.LEFT) _keyboardEvent._keyLocation = KeyLocation.LEFT;
    if (event.keyLocation == html.KeyLocation.RIGHT) _keyboardEvent._keyLocation = KeyLocation.RIGHT;
    if (event.keyLocation == html.KeyLocation.NUMPAD) _keyboardEvent._keyLocation = KeyLocation.NUM_PAD;
    if (event.keyLocation == html.KeyLocation.JOYSTICK) _keyboardEvent._keyLocation = KeyLocation.D_PAD;
    if (event.keyLocation == html.KeyLocation.MOBILE) _keyboardEvent._keyLocation = KeyLocation.D_PAD;

    if (_focus != null)
      _focus.dispatchEvent(_keyboardEvent);
  }

  //-------------------------------------------------------------------------------------------------

  _onTextEvent(html.KeyboardEvent event) {
    
    int charCode = (event.charCode != 0) ? event.charCode : event.keyCode;

    TextEvent textEvent = new TextEvent(TextEvent.TEXT_INPUT, true);
    textEvent._text = new String.fromCharCodes([charCode]);

    if (_focus != null)
      _focus.dispatchEvent(textEvent);
  }

}
