class Stage extends DisplayObjectContainer
{
  html.CanvasElement _canvas;
  html.CanvasRenderingContext2D _context;

  InteractiveObject _focus;
  RenderState _renderState;
  String _renderMode;
  String _mouseCursor;
  Point _canvasLocation;

  List<bool> _buttonState;
  List<DisplayObject> _clickTarget;
  List<int> _clickTime;
  List<int> _clickCount;
  List<String> _mouseDownEventTypes;
  List<String> _mouseUpEventTypes;
  List<String> _mouseClickEventTypes;
  List<String> _mouseDoubleClickEventTypes;
  InteractiveObject _mouseOverTarget;

  //-------------------------------------------------------------------------------------------------

  Stage(String name, html.CanvasElement canvas)
  {
    _name = name;

    _canvas = canvas;
    _canvas.style.outline = "none";
    _canvas.focus();

    _context = canvas.context2d;

    _canvasLocation = null;
    _calculateElementLocation(_canvas).then((point) => _canvasLocation = point);

    _renderState = new RenderState.fromCanvasRenderingContext2D(_context);
    _renderMode = StageRenderMode.AUTO;
    _mouseCursor = MouseCursor.ARROW;

    //-----------

    _buttonState = [false, false, false];

    _clickTarget = [null, null, null];
    _clickTime = [0, 0, 0];
    _clickCount = [0, 0, 0];

    _mouseDownEventTypes = [MouseEvent.MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_DOWN];
    _mouseUpEventTypes =  [MouseEvent.MOUSE_UP, MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.RIGHT_MOUSE_UP];
    _mouseClickEventTypes = [MouseEvent.CLICK, MouseEvent.MIDDLE_CLICK, MouseEvent.RIGHT_CLICK];
    _mouseDoubleClickEventTypes = [MouseEvent.DOUBLE_CLICK, MouseEvent.MIDDLE_CLICK, MouseEvent.RIGHT_CLICK];

    _mouseOverTarget = null;

    _canvas.on.mouseDown.add(_onMouseEvent);
    _canvas.on.mouseUp.add(_onMouseEvent);
    _canvas.on.mouseMove.add(_onMouseEvent);
    _canvas.on.mouseOut.add(_onMouseEvent);

    _canvas.on.mouseWheel.add(_onMouseWheel);

    _canvas.on.keyDown.add(_onKeyEvent);
    _canvas.on.keyUp.add(_onKeyEvent);
    _canvas.on.keyPress.add(_onTextEvent);

    //-----------

    Mouse._eventDispatcher.addEventListener("mouseCursorChanged", _onMouseCursorChanged);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int stageWidth() => _canvas.width;
  int stageHeight() => _canvas.height;

  InteractiveObject get focus() => _focus;
  void set focus(InteractiveObject value) { _focus = value; }

  String get renderMode() => _renderMode;
  void set renderMode(String value) { _renderMode = value; }

  //-------------------------------------------------------------------------------------------------

  void _throwStageException() { throw new Exception("Error #2071: The Stage class does not implement this property or method."); }

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
    
    int time = new Date.now().millisecondsSinceEpoch;
    int button = event.button;
    InteractiveObject target = null;
    MouseEvent mouseEvent = null;

    if (_canvasLocation == null || button < 0 || button > 2)
      return;

    var mouseX = event.offsetX;
    var mouseY = event.offsetY;

    if (mouseX == null || mouseY == null) {  
      mouseX = event.pageX - _canvasLocation.x;
      mouseY = event.pageY - _canvasLocation.y;
    }

    Point stagePoint = new Point(mouseX, mouseY);
    Point localPoint = null;

    if (event.type != "mouseout")
      target = hitTestInput(stagePoint.x, stagePoint.y);

    //------------------------------------------------------

    String mouseCursor = MouseCursor.ARROW;

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

    if (_mouseOverTarget != null && _mouseOverTarget != target)
    {
      if (_mouseOverTarget.stage != null)
        localPoint = _mouseOverTarget.globalToLocal(stagePoint);
      else
        localPoint = new Point.zero();

      mouseEvent = new MouseEvent(MouseEvent.MOUSE_OUT, true);
      mouseEvent._localX = localPoint.x;
      mouseEvent._localY = localPoint.y;
      mouseEvent._stageX = stagePoint.x;
      mouseEvent._stageY = stagePoint.y;
      mouseEvent._buttonDown = _buttonState[button];

      _mouseOverTarget.dispatchEvent(mouseEvent);
      _mouseOverTarget = null;
    }

    if (target != null && target != _mouseOverTarget)
    {
      localPoint = target.globalToLocal(stagePoint);

      mouseEvent = new MouseEvent(MouseEvent.MOUSE_OVER, true);
      mouseEvent._localX = localPoint.x;
      mouseEvent._localY = localPoint.y;
      mouseEvent._stageX = stagePoint.x;
      mouseEvent._stageY = stagePoint.y;
      mouseEvent._buttonDown = _buttonState[button];

      _mouseOverTarget = target;
      _mouseOverTarget.dispatchEvent(mouseEvent);
    }

    //------------------------------------------------------

    String mouseEventType = null;
    int clickCount = _clickCount[button];
    bool isClick = false;
    bool isDoubleClick = false;

    if (event.type == "mousedown") 
    {
        mouseEventType = _mouseDownEventTypes[button];

        _buttonState[button] = true;

        if (target != _clickTarget[button] || time > _clickTime[button] + 500) clickCount = 0;

        _clickTarget[button] = target;
        _clickTime[button] = time;
        _clickCount[button] = ++clickCount;
    }

    if (event.type == "mouseup")
    {
        mouseEventType = _mouseUpEventTypes[button];

        _buttonState[button] = false;

        isClick = (_clickTarget[button] == target);
        isDoubleClick = isClick && _clickCount[button].isEven() && (time < _clickTime[button] + 500);
    }

    if (event.type == "mousemove")
    {
        mouseEventType = MouseEvent.MOUSE_MOVE;
        clickCount = 0;
    }

    //-----------------------------------------------------------------

    if (mouseEventType != null && target != null)
    {
      localPoint = target.globalToLocal(stagePoint);

      mouseEvent = new MouseEvent(mouseEventType, true);
      mouseEvent._localX = localPoint.x;
      mouseEvent._localY = localPoint.y;
      mouseEvent._stageX = stagePoint.x;
      mouseEvent._stageY = stagePoint.y;
      mouseEvent._buttonDown = _buttonState[button];
      mouseEvent._clickCount = clickCount;

      target.dispatchEvent(mouseEvent);

      //----------------------------------------------

      if (isClick)
      {
        isDoubleClick = isDoubleClick && target.doubleClickEnabled;
        mouseEventType = isDoubleClick ? _mouseDoubleClickEventTypes[button] : _mouseClickEventTypes[button];

        mouseEvent = new MouseEvent(mouseEventType, true);
        mouseEvent._localX = localPoint.x;
        mouseEvent._localY = localPoint.y;
        mouseEvent._stageX = stagePoint.x;
        mouseEvent._stageY = stagePoint.y;
        mouseEvent._buttonDown = _buttonState[button];

        target.dispatchEvent(mouseEvent);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _onMouseWheel(html.WheelEvent event)
  {
    var mouseX = event.offsetX;
    var mouseY = event.offsetY;

    if ((mouseX == null || mouseY == null) && _canvasLocation != null)  // firefox workaround
    {
      mouseX = event.pageX - _canvasLocation.x;
      mouseY = event.pageY - _canvasLocation.y;
    }

    InteractiveObject target = hitTestInput(mouseX, mouseY);

    if (target != null)
    {
      Point stagePoint = new Point(event.offsetX, event.offsetY);
      Point localPoint = target.globalToLocal(stagePoint);

      MouseEvent mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true);
      mouseEvent._localX = localPoint.x;
      mouseEvent._localY = localPoint.y;
      mouseEvent._stageX = stagePoint.x;
      mouseEvent._stageY = stagePoint.y;
      mouseEvent._delta = event.wheelDelta;

      target.dispatchEvent(mouseEvent);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void _onKeyEvent(html.KeyboardEvent event)
  {
    event.preventDefault();
    
    String keyboardEventType = null;

    if (event.type == "keyup") keyboardEventType = KeyboardEvent.KEY_UP;
    if (event.type == "keydown") keyboardEventType = KeyboardEvent.KEY_DOWN;

    KeyboardEvent keyboardEvent = new KeyboardEvent(keyboardEventType, true);
    keyboardEvent._altKey = event.altKey;
    keyboardEvent._ctrlKey = event.ctrlKey;
    keyboardEvent._shiftKey = event.shiftKey;
    keyboardEvent._charCode = event.charCode;
    keyboardEvent._keyCode = event.keyCode;
    keyboardEvent._keyLocation = KeyLocation.STANDARD;

    if (event.keyLocation == html.KeyLocation.LEFT) keyboardEvent._keyLocation = KeyLocation.LEFT;
    if (event.keyLocation == html.KeyLocation.RIGHT) keyboardEvent._keyLocation = KeyLocation.RIGHT;
    if (event.keyLocation == html.KeyLocation.NUMPAD) keyboardEvent._keyLocation = KeyLocation.NUM_PAD;
    if (event.keyLocation == html.KeyLocation.JOYSTICK) keyboardEvent._keyLocation = KeyLocation.D_PAD;
    if (event.keyLocation == html.KeyLocation.MOBILE) keyboardEvent._keyLocation = KeyLocation.D_PAD;

    if (_focus != null)
      _focus.dispatchEvent(keyboardEvent);
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

  //-------------------------------------------------------------------------------------------------

  Future<Point> _calculateElementLocation(html.Element element)
  {
    Completer<Point> completer = new Completer<Point>();

    element.rect.then((rect)
    {
      Point point = new Point(rect.offset.left, rect.offset.top);

      if (element.offsetParent != null)
        _calculateElementLocation(element.offsetParent).then((p) => completer.complete(point.add(p)));
      else
        completer.complete(point);
    });

    return completer.future;
  }
}
