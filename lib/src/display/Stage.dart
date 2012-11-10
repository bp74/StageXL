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
    _canvas.style.outline = "none";
    _canvas.focus();

    _context = canvas.context2d;

    _renderState = new RenderState.fromCanvasRenderingContext2D(_context);
    _renderMode = StageRenderMode.AUTO;
    _mouseCursor = MouseCursor.ARROW;

    //---------------------------
    // prepare mouse events

    Mouse._eventDispatcher.addEventListener("mouseCursorChanged", _onMouseCursorChanged);

    _mouseButtons = [
      new _MouseButton(MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK),
      new _MouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_CLICK),
      new _MouseButton(MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP, MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_CLICK)
    ];

    _mouseTarget = null;
    _mousePosition = new Point(0, 0);
    _mouseEvent = new MouseEvent(MouseEvent.CLICK, true);

    _canvas.on.mouseDown.add(_onMouseEvent);
    _canvas.on.mouseUp.add(_onMouseEvent);
    _canvas.on.mouseMove.add(_onMouseEvent);
    _canvas.on.mouseOut.add(_onMouseEvent);
    _canvas.on.mouseWheel.add(_onMouseWheel);

    //---------------------------
    // prepare touch events

    _touches = new Map<int, _Touch>();
    _touchEvent = new TouchEvent(TouchEvent.TOUCH_BEGIN, true);

    if (Multitouch.supportsTouchEvents)
    {
      _canvas.on.touchStart.add(_onTouchEvent);
      _canvas.on.touchEnd.add(_onTouchEvent);
      _canvas.on.touchMove.add(_onTouchEvent);
      _canvas.on.touchEnter.add(_onTouchEvent);
      _canvas.on.touchLeave.add(_onTouchEvent);
    }

    //---------------------------
    // prepare keyboard events

    _keyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, true);

    _canvas.on.keyDown.add(_onKeyEvent);
    _canvas.on.keyUp.add(_onKeyEvent);
    _canvas.on.keyPress.add(_onTextEvent);
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

  void _onMouseCursorChanged(Event event)
  {
    _canvas.style.cursor = Mouse._getCssStyle(_mouseCursor);
  }

  //-------------------------------------------------------------------------------------------------

  void _onMouseEvent(html.MouseEvent event)
  {
    event.preventDefault();

    var clientRect = _canvas.getBoundingClientRect();
    var time = new Date.now().millisecondsSinceEpoch;
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

    //------------------------------------------------------

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

    //------------------------------------------------------

    if (_mouseTarget != null && _mouseTarget != target)
    {
      if (_mouseTarget.stage != null)
        localPoint = _mouseTarget.globalToLocal(stagePoint);
      else
        localPoint = new Point.zero();

      _mouseEvent._reset(MouseEvent.MOUSE_OUT, true);
      _mouseEvent._localX = localPoint.x;
      _mouseEvent._localY = localPoint.y;
      _mouseEvent._stageX = stagePoint.x;
      _mouseEvent._stageY = stagePoint.y;
      _mouseEvent._buttonDown = mouseButton.buttonDown;

      _mouseTarget.dispatchEvent(_mouseEvent);
      _mouseTarget = null;
    }

    if (target != null && target != _mouseTarget)
    {
      localPoint = target.globalToLocal(stagePoint);

      _mouseEvent._reset(MouseEvent.MOUSE_OVER, true);
      _mouseEvent._localX = localPoint.x;
      _mouseEvent._localY = localPoint.y;
      _mouseEvent._stageX = stagePoint.x;
      _mouseEvent._stageY = stagePoint.y;
      _mouseEvent._buttonDown = mouseButton.buttonDown;

      _mouseTarget = target;
      _mouseTarget.dispatchEvent(_mouseEvent);
    }

    //------------------------------------------------------

    String mouseEventType = null;
    bool isClick = false;
    bool isDoubleClick = false;

    if (event.type == "mousedown")
    {
        mouseEventType = mouseButton.mouseDownEventType;

        if (target != mouseButton.target || time > mouseButton.clickTime + 500)
          mouseButton.clickCount = 0;

        mouseButton.buttonDown = true;
        mouseButton.target = target;
        mouseButton.clickTime = time;
        mouseButton.clickCount++;
    }

    if (event.type == "mouseup")
    {
        mouseEventType = mouseButton.mouseUpEventType;
        mouseButton.buttonDown = false;

        isClick = (mouseButton.target == target);
        isDoubleClick = isClick && mouseButton.clickCount.isEven && (time < mouseButton.clickTime + 500);
    }

    if (event.type == "mousemove")
    {
        mouseEventType = MouseEvent.MOUSE_MOVE;

        for(int i = 0; i < _mouseButtons.length; i++) {
          _mouseButtons[i].clickCount = 0;
          _mouseButtons[i].target = null;
        }
    }

    //-----------------------------------------------------------------

    if (mouseEventType != null && target != null)
    {
      localPoint = target.globalToLocal(stagePoint);

      _mouseEvent._reset(mouseEventType, true);
      _mouseEvent._localX = localPoint.x;
      _mouseEvent._localY = localPoint.y;
      _mouseEvent._stageX = stagePoint.x;
      _mouseEvent._stageY = stagePoint.y;
      _mouseEvent._buttonDown = mouseButton.buttonDown;
      _mouseEvent._clickCount = mouseButton.clickCount;

      target.dispatchEvent(_mouseEvent);

      //----------------------------------------------

      if (isClick)
      {
        mouseEventType = mouseButton.mouseClickEventType;

        if (isDoubleClick && target.doubleClickEnabled)
          mouseEventType = mouseButton.mouseDoubleClickEventType;

        _mouseEvent._reset(mouseEventType, true);
        _mouseEvent._localX = localPoint.x;
        _mouseEvent._localY = localPoint.y;
        _mouseEvent._stageX = stagePoint.x;
        _mouseEvent._stageY = stagePoint.y;
        _mouseEvent._buttonDown = mouseButton.buttonDown;

        target.dispatchEvent(_mouseEvent);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _onMouseWheel(html.WheelEvent event)
  {
    InteractiveObject target = hitTestInput(event.offsetX, event.offsetY);

    if (target != null)
    {
      Point stagePoint = new Point(event.offsetX, event.offsetY);
      Point localPoint = target.globalToLocal(stagePoint);

      _mouseEvent._reset(MouseEvent.MOUSE_WHEEL, true);
      _mouseEvent._localX = localPoint.x;
      _mouseEvent._localY = localPoint.y;
      _mouseEvent._stageX = stagePoint.x;
      _mouseEvent._stageY = stagePoint.y;
      _mouseEvent._deltaX = event.deltaX;
      _mouseEvent._deltaY = event.deltaY;

      target.dispatchEvent(_mouseEvent);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _onTouchEvent(html.TouchEvent event)
  {
    event.preventDefault();

    print("event.type -> ${event.type}");

    var clientRect = _canvas.getBoundingClientRect();

    for(var changedTouch in event.changedTouches)
    {
      int identifier = changedTouch.identifier;
      InteractiveObject target = null;
      Point stagePoint = new Point(changedTouch.clientX - clientRect.left, changedTouch.clientY - clientRect.top);
      Point localPoint = null;

      if (_touches.containsKey(identifier) == false)
        _touches[identifier] = new _Touch();

      _Touch touch = _touches[identifier];

      print("  identifier:$identifier, touchPointID:${touch.touchPointID} - x:${stagePoint.x}, y:${stagePoint.y}");
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

    _keyboardEvent._reset(keyboardEventType, true);
    _keyboardEvent._altKey = event.altKey;
    _keyboardEvent._ctrlKey = event.ctrlKey;
    _keyboardEvent._shiftKey = event.shiftKey;
    _keyboardEvent._charCode = event.charCode;
    _keyboardEvent._keyCode = event.keyCode;
    _keyboardEvent._keyLocation = KeyLocation.STANDARD;

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
