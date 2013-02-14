part of dartflash;

class _MouseButton
{
  InteractiveObject target = null;
  bool buttonDown = false;
  int clickTime = 0;
  int clickCount = 0;
  String mouseDownEventType, mouseUpEventType;
  String mouseClickEventType, mouseDoubleClickEventType;

  _MouseButton(this.mouseDownEventType, this.mouseUpEventType, this.mouseClickEventType, this.mouseDoubleClickEventType);
}

class _Touch
{
  static int _globalTouchPointID = 0;

  int touchPointID = _globalTouchPointID++;
  InteractiveObject target = null;
  bool primaryTouchPoint = false;

  _Touch(this.target, this.primaryTouchPoint);
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class Stage extends DisplayObjectContainer
{
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;

  InteractiveObject _focus;
  RenderState _renderState;
  String _renderMode;

  String _mouseCursor;
  Point _mousePosition;
  InteractiveObject _mouseTarget;
  List<_MouseButton> _mouseButtons;
  Map<int, _Touch> _touches;

  MouseEvent _mouseEvent;
  KeyboardEvent _keyboardEvent;
  TouchEvent _touchEvent;

  //-------------------------------------------------------------------------------------------------

  Stage(String name, CanvasElement canvas)
  {
    _name = name;

    _canvas = canvas;
    _canvas.focus();

    _context = canvas.context2d;

    _renderState = new RenderState.fromCanvasRenderingContext2D(_context);
    _renderMode = StageRenderMode.AUTO;
    _mouseCursor = MouseCursor.ARROW;

    //---------------------------
    // prepare mouse events

    Mouse._onMouseCursorChanged.listen(_onMouseCursorChanged);

    _mouseButtons = [
      new _MouseButton(MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK),
      new _MouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_CLICK),
      new _MouseButton(MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP, MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_CLICK)
    ];

    _mouseTarget = null;
    _mousePosition = new Point(0, 0);
    _mouseEvent = new MouseEvent(MouseEvent.CLICK, true);

    _canvas.onMouseDown.listen(_onMouseEvent);
    _canvas.onMouseUp.listen(_onMouseEvent);
    _canvas.onMouseMove.listen(_onMouseEvent);
    _canvas.onMouseOut.listen(_onMouseEvent);
    _canvas.onMouseWheel.listen(_onMouseEvent);

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

  int stageWidth() => _canvas.width;
  int stageHeight() => _canvas.height;

  InteractiveObject get focus => _focus;
  void set focus(InteractiveObject value) { _focus = value; }

  String get renderMode => _renderMode;
  void set renderMode(String value) { _renderMode = value; }

  //-------------------------------------------------------------------------------------------------

  void _throwStageException() {
    throw new UnsupportedError("Error #2071: The Stage class does not implement this property or method.");
  }

  void set x(num value) { _throwStageException(); }
  void set y(num value) { _throwStageException(); }
  void set pivotX(num value) { _throwStageException(); }
  void set pivotY(num value) { _throwStageException(); }
  void set scaleX(num value) { _throwStageException(); }
  void set scaleY(num value) { _throwStageException(); }
  void set rotation(num value) { _throwStageException(); }
  void set alpha(num value) { _throwStageException(); }
  void set width(num value) { _throwStageException(); }
  void set height(num value) { _throwStageException(); }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void materialize()
  {
    if (_renderMode == StageRenderMode.AUTO || _renderMode == StageRenderMode.ONCE)
    {
      _renderState.reset();
      render(_renderState);

      if (_renderMode == StageRenderMode.ONCE)
        _renderMode = StageRenderMode.STOP;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onMouseCursorChanged(String action)
  {
    _canvas.style.cursor = Mouse._getCssStyle(_mouseCursor);
  }

  //-------------------------------------------------------------------------------------------------

  void _onMouseEvent(html.MouseEvent event)
  {
    event.preventDefault();

    var clientRect = _canvas.getBoundingClientRect();
    var time = new DateTime.now().millisecondsSinceEpoch;
    var button = event.button;

    InteractiveObject target = null;
    Point stagePoint = new Point(event.clientX - clientRect.left, event.clientY - clientRect.top);
    Point localPoint = null;

    if (button < 0 || button > 2) return;
    if (event.type == "mousemove" && _mousePosition.equals(stagePoint)) return;

    _MouseButton mouseButton = _mouseButtons[button];
    _mousePosition = stagePoint;

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

  void _onMouseWheel(html.WheelEvent event)
  {
    var clientRect = _canvas.getBoundingClientRect();
    var stagePoint = new Point(event.clientX - clientRect.left, event.clientY - clientRect.top);
    var target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;

    if (target != null) {
      target.dispatchEvent(_mouseEvent
        .._reset(MouseEvent.MOUSE_WHEEL, true)
        .._localPoint = target.globalToLocal(stagePoint)
        .._stagePoint = stagePoint
        .._deltaX = event.deltaX
        .._deltaY = event.deltaY);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  List<StreamSubscription<TouchEvent>> _touchEventSubscriptions = [];
  
  void _onMultitouchInputModeChanged(String inputMode)
  {
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

  void _onTouchEvent(html.TouchEvent event)
  {
    event.preventDefault();

    var clientRect = _canvas.getBoundingClientRect();

    for(var changedTouch in event.changedTouches) {

      var identifier = changedTouch.identifier;
      var stagePoint = new Point(changedTouch.clientX - clientRect.left, changedTouch.clientY - clientRect.top);
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

  void _onKeyEvent(html.KeyboardEvent event)
  {
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

  void _onTextEvent(html.KeyboardEvent event)
  {
    int charCode = (event.charCode != 0) ? event.charCode : event.keyCode;

    TextEvent textEvent = new TextEvent(TextEvent.TEXT_INPUT, true);
    textEvent._text = new String.fromCharCodes([charCode]);

    if (_focus != null)
      _focus.dispatchEvent(textEvent);
  }

}
