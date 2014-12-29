part of stagexl.display;

/// The Stage is the drawing area wher all display objects are rendered to.
/// Place a Canvas element to your HTML and use the Stage to wrap all the
/// rendering functions to this Canvas element.
///
/// Example:
///
/// HTML: <canvas id="stage" width="800" height="600"></canvas>
/// Dart: var stage = new Stage(querySelector("#stage"));

class Stage extends DisplayObjectContainer {

  static bool autoHiDpi = env.autoHiDPI;
  static bool get isMobile => env.isMobileDevice;
  static num get devicePixelRatio => env.devicePixelRatio;

  CanvasElement _canvas;
  RenderContext _renderContext;
  Juggler _juggler = new Juggler();
  RenderLoop _renderLoop = null;

  int _color = 0;
  int _sourceWidth = 0;
  int _sourceHeight = 0;
  int _frameRate = 30;
  int _stageWidth = 0;
  int _stageHeight = 0;
  Rectangle<num> _contentRectangle = new Rectangle<num>(0.0, 0.0, 0.0, 0.0);

  Matrix _clientTransformation = new Matrix.fromIdentity();
  Matrix _stageTransformation = new Matrix.fromIdentity();

  InteractiveObject _focus = null;
  RenderState _renderState = null;
  StageRenderMode _stageRenderMode = StageRenderMode.AUTO;
  StageScaleMode _stageScaleMode = StageScaleMode.SHOW_ALL;
  StageAlign _stageAlign = StageAlign.NONE;

  String _mouseCursor = MouseCursor.DEFAULT;
  Point<num> _mousePosition = new Point<num>(0.0, 0.0);
  InteractiveObject _mouseTarget = null;

  List<_Drag> _drags = new List<_Drag>();
  Map<int, _TouchPoint> _touchPoints = new Map<int, _TouchPoint>();
  List<_MouseButton> _mouseButtons = _MouseButton.createDefaults();

  //----------------------------------------------------------------------------

  static const EventStreamProvider<Event> resizeEvent =
      const EventStreamProvider<Event>(Event.RESIZE);

  static const EventStreamProvider<Event> mouseLeaveEvent =
      const EventStreamProvider<Event>(Event.MOUSE_LEAVE);

  EventStream<Event> get onResize => Stage.resizeEvent.forTarget(this);
  EventStream<Event> get onMouseLeave => Stage.mouseLeaveEvent.forTarget(this);

  //----------------------------------------------------------------------------

  Stage(CanvasElement canvas, {int width, int height,
    bool webGL: false, bool alpha: false, int frameRate: 30,
    int color: Color.White}) {

    if (canvas is! CanvasElement) {
      throw new ArgumentError("The canvas argument is not a CanvasElement");
    }

    _canvas = canvas;

    if (canvas.tabIndex == -1) canvas.tabIndex = 0;
    if (canvas.style.outline == "") canvas.style.outline = "none";

    _color = ensureInt(color);
    _sourceWidth = ensureInt((width != null) ? width : canvas.width);
    _sourceHeight = ensureInt((width != null) ? height : canvas.height);
    _frameRate = ensureInt((frameRate != null) ? frameRate : 30);

    if (webGL && gl.RenderingContext.supported) {
      try {
        _renderContext = new RenderContextWebGL(canvas, alpha: alpha);
      } catch (e) {
        _renderContext = new RenderContextCanvas(canvas);
      }
    } else {
      _renderContext = new RenderContextCanvas(canvas);
    }

    _renderState = new RenderState(_renderContext);
    _updateCanvasSize();

    print("StageXL render engine : ${_renderContext.renderEngine}");

    canvas.onKeyDown.listen(_onKeyEvent);
    canvas.onKeyUp.listen(_onKeyEvent);
    canvas.onKeyPress.listen(_onKeyEvent);
    canvas.onMouseDown.listen(_onMouseEvent);
    canvas.onMouseUp.listen(_onMouseEvent);
    canvas.onMouseMove.listen(_onMouseEvent);
    canvas.onMouseOut.listen(_onMouseEvent);
    canvas.onContextMenu.listen(_onMouseEvent);
    canvas.onMouseWheel.listen(_onMouseWheelEvent);

    Mouse.onCursorChanged.listen((cursorName) => _updateMouseCursor());
    Multitouch.onInputModeChanged.listen(_onMultitouchInputModeChanged);

    _onMultitouchInputModeChanged(Multitouch.inputMode);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Gets the underlying render engine used to draw the pixels to the screen.
  /// The returned string is defined in [RenderEngine] and is either "WebGL"
  /// or "Canvas2D".

  String get renderEngine => _renderContext.renderEngine;

  /// Gets the [RenderLoop] where this Stage was added to, or
  /// NULL in case this Stage is not added to a [RenderLoop].

  RenderLoop get renderLoop => _renderLoop;

  /// Gets the [Juggler] of this Stage. The Juggler is driven by the
  /// [RenderLoop] where this Stage is added to. If this Stage is not
  /// added to a RenderLoop, the [Juggler] will not advance in time.

  Juggler get juggler => _juggler;

  /// Gets the last known mouse position in Stage coordinates.

  Point<num> get mousePosition => _mousePosition;

  /// Gets the available content area on the stage. The value of this rectangle
  /// changes with the scaleMode and the alignment of the stage, as well as the
  /// size of the underlying Canvas element.

  Rectangle<num> get contentRectangle => _contentRectangle.clone();

  /// Gets the width of the Stage in screen coordinates/pixels.

  int get stageWidth => _stageWidth;

  /// Gets the height of the Stage in screen coordinates/pixels.

  int get stageHeight => _stageHeight;

  /// Gets and sets the width of the Stage in world coordinates.
  /// The initial value of [sourceWidth] is the width of the canvas
  /// element or the width provided in the constructor of the Stage.

  int get sourceWidth => _sourceWidth;

  void set sourceWidth(int value) {
    _sourceWidth = ensureInt(value);
    _updateCanvasSize();
  }

  /// Gets and sets the height of the Stage in world coordinates.
  /// The initial value of [sourceHeight] is the height of the canvas
  /// element or the height provided in the constructor of the Stage.

  int get sourceHeight => _sourceHeight;

  void set sourceHeight(int value) {
    _sourceHeight = ensureInt(value);
    _updateCanvasSize();
  }

  /// Gets and sets the default frame rate for MovieClips. This value has no
  /// impact on the frame rate of the Stage itself.

  int get frameRate => _frameRate;

  void set frameRate(int value) {
    _frameRate = value;
  }

  /// Gets and sets the [InteractiveObject] (a DisplayObject which can
  /// receive user input like mouse, touch or keyboard).

  InteractiveObject get focus => _focus;

  void set focus(InteractiveObject value) {
    _focus = value;
  }

  /// Gets and sets the render mode of this Stage. You can choose between
  /// three different modes defined in [StageRenderMode].

  StageRenderMode get renderMode => _stageRenderMode;

  void set renderMode(StageRenderMode value) {
    _stageRenderMode = value;
  }

  /// Gets and sets the scale mode of this Stage. You can choose between
  /// four dfferent modes defined in [StageScaleMode].

  StageScaleMode get scaleMode => _stageScaleMode;

  void set scaleMode(StageScaleMode value) {
    _stageScaleMode = value;
    _updateCanvasSize();
  }

  /// Gets and sets the alignment of this Stage inside of the Canvas element.
  /// You can choose between nine different align modes defined in [StageAlign].

  StageAlign get align => _stageAlign;

  void set align(StageAlign value) {
    _stageAlign = value;
    _updateCanvasSize();
  }

  /// Gets and sets the background color of this Stage.

  int get backgroundColor => _color;

  void set backgroundColor(int value) {
    _color = value;
  }

  //----------------------------------------------------------------------------

  _throwStageException() {
    throw new UnsupportedError(
        "The Stage class does not implement this property or method.");
  }

  void set x(num value) { _throwStageException(); }
  void set y(num value) { _throwStageException(); }
  void set pivotX(num value) { _throwStageException(); }
  void set pivotY(num value) { _throwStageException(); }
  void set scaleX(num value) { _throwStageException(); }
  void set scaleY(num value) { _throwStageException(); }
  void set skewX(num value) { _throwStageException(); }
  void set skewY(num value) { _throwStageException(); }
  void set rotation(num value) { _throwStageException(); }
  void set alpha(num value) { _throwStageException(); }
  void set width(num value) { _throwStageException(); }
  void set height(num value) { _throwStageException(); }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    var target = super.hitTestInput(localX, localY);
    return target != null ? target : this;
  }

  //----------------------------------------------------------------------------

  /// Calling this method will cause an [RenderEvent] to be fired right before
  /// the next frame will be rendered by the render loop. To receive the render
  /// event attach a listener to [DisplayObject.onRender].

  invalidate() {
    if (_renderLoop != null) {
      _renderLoop.invalidate();
    }
  }

  //----------------------------------------------------------------------------

  /// This method is called by the [RenderLoop] where this Stage is added to.
  /// If this Stage is not added to a [RenderLoop] you could call this method
  /// on your own and therefore get full control of the rendering of this Stage.

  void materialize(num currentTime, num deltaTime) {

    if (_stageRenderMode == StageRenderMode.AUTO ||
        _stageRenderMode == StageRenderMode.ONCE) {

      _updateCanvasSize();

      _renderContext.reset();
      _renderContext.clear(_color);

      _renderState.reset(_stageTransformation);
      _renderState.currentTime = ensureNum(currentTime);
      _renderState.deltaTime = ensureNum(deltaTime);
      _renderState.renderObject(this);
      _renderState.flush();

      if (_stageRenderMode == StageRenderMode.ONCE) {
        _stageRenderMode = StageRenderMode.STOP;
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  void _startDrag(Sprite sprite, Point<num> globalPoint, Point<num> anchorPoint,
                  Rectangle<num> bounds, int touchPointID) {

    var drag = new _Drag(this, sprite, anchorPoint, bounds, touchPointID);
    drag.update(touchPointID, globalPoint);

    _drags.removeWhere((d) => d.touchPointID == touchPointID || d.sprite == sprite);
    _drags.add(drag);
  }

  void _stopDrag(Sprite sprite) {
    _drags.removeWhere((d) => d.sprite == sprite);
  }

  //----------------------------------------------------------------------------

  _updateCanvasSize() {

    int clientLeft, clientTop;
    int clientWidth, clientHeight;
    int sourceWidth = _sourceWidth;
    int sourceHeight = _sourceHeight;

    if (env.isCocoonJS) {
      clientLeft = 0;
      clientTop = 0;
      clientWidth = html.window.innerWidth;
      clientHeight = html.window.innerHeight;
    } else {
      var clientRectangle = _canvas.getBoundingClientRect();
      clientLeft = _canvas.clientLeft + clientRectangle.left.round();
      clientTop = _canvas.clientTop + clientRectangle.top.round();
      clientWidth = _canvas.clientWidth;
      clientHeight = _canvas.clientHeight;
    }

    if (clientWidth is! num) throw "dart2js_hint";
    if (clientHeight is! num) throw "dart2js_hint";
    if (sourceWidth is! num) throw "dart2js_hint";
    if (sourceHeight is! num) throw "dart2js_hint";

    if (clientWidth == 0 || clientHeight == 0) return;

    //----------------------------

    double scaleX = 1.0;
    double scaleY = 1.0;
    double pivotX = 0.0;
    double pivotY = 0.0;
    double ratioWidth = clientWidth / sourceWidth;
    double ratioHeight = clientHeight / sourceHeight;

    switch(_stageScaleMode) {
      case StageScaleMode.EXACT_FIT:
        scaleX = ratioWidth;
        scaleY = ratioHeight;
        break;
      case StageScaleMode.NO_BORDER:
        scaleX = scaleY = (ratioWidth > ratioHeight) ? ratioWidth : ratioHeight;
        break;
      case StageScaleMode.NO_SCALE:
        scaleX = scaleY = 1.0;
        break;
      case StageScaleMode.SHOW_ALL:
        scaleX = scaleY = (ratioWidth < ratioHeight) ? ratioWidth : ratioHeight;
        break;
    }

    switch (_stageAlign) {
      case StageAlign.TOP_RIGHT:
      case StageAlign.RIGHT:
      case StageAlign.BOTTOM_RIGHT:
        pivotX = (clientWidth - sourceWidth * scaleX);
        break;
      case StageAlign.TOP:
      case StageAlign.NONE:
      case StageAlign.BOTTOM:
        pivotX = (clientWidth - sourceWidth * scaleX) / 2;
        break;
    }

    switch (_stageAlign) {
      case StageAlign.BOTTOM_LEFT:
      case StageAlign.BOTTOM:
      case StageAlign.BOTTOM_RIGHT:
        pivotY = (clientHeight - sourceHeight * scaleY);
        break;
      case StageAlign.LEFT:
      case StageAlign.NONE:
      case StageAlign.RIGHT:
        pivotY = (clientHeight - sourceHeight * scaleY) / 2;
        break;
    }

    //----------------------------

    var contentRectangle = _contentRectangle;
    contentRectangle.left = - pivotX / scaleX;
    contentRectangle.top = - pivotY / scaleY;
    contentRectangle.width = clientWidth / scaleX;
    contentRectangle.height = clientHeight / scaleY;

    var pixelRatio = Stage.autoHiDpi ? devicePixelRatio : 1.0;

    // stage to canvas coordinate transformation
    _stageTransformation.setTo(scaleX, 0.0, 0.0, scaleY, pivotX, pivotY);
    _stageTransformation.scale(pixelRatio, pixelRatio);

    // client to stage coordinate transformation
    _clientTransformation.setTo(
        1.0, 0.0, 0.0, 1.0, - clientLeft - pivotX, - clientTop - pivotY);
    _clientTransformation.scale(1.0 / scaleX, 1.0 / scaleY);

    //----------------------------

    if (_stageWidth != clientWidth || _stageHeight != clientHeight) {

      _stageWidth = clientWidth;
      _stageHeight = clientHeight;
      _canvas.width = (clientWidth * pixelRatio).round();
      _canvas.height = (clientHeight * pixelRatio).round();

      // update hi-dpi canvas style size if client size has changed

      if (_canvas.clientWidth != clientWidth ||
          _canvas.clientHeight != clientHeight) {
        _canvas.style.width = "${clientWidth}px";
        _canvas.style.height = "${clientHeight}px";
      }

      dispatchEvent(new Event(Event.RESIZE));
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  _updateMouseCursor() {

    var mouseTarget = _mouseTarget;
    var mouseCursor = Mouse.cursor;

    if (mouseTarget != null && mouseCursor == MouseCursor.AUTO) {
      var mc = mouseTarget.mouseCursor;
      if (mc != null && mc != MouseCursor.AUTO) mouseCursor = mc;
    }

    if (mouseCursor == MouseCursor.AUTO) {
      mouseCursor = MouseCursor.DEFAULT;
    }

    if (_mouseCursor != mouseCursor) {
      _mouseCursor = mouseCursor;
      _canvas.style.cursor = Mouse.getCursorStyle(mouseCursor);
    }
  }

  //----------------------------------------------------------------------------

  _onMouseEvent(html.MouseEvent event) {

    event.preventDefault();

    int time = new DateTime.now().millisecondsSinceEpoch;
    int button = event.button;

    InteractiveObject target = null;
    Point stagePoint = _clientTransformation.transformPoint(event.client);
    Point localPoint = new Point<num>(0.0, 0.0);

    if (button < 0 || button > 2) return;
    if (event.type == "mousemove" && _mousePosition.equals(stagePoint)) return;

    _MouseButton mouseButton = _mouseButtons[button];
    _mousePosition = stagePoint;
    _drags.forEach((d) => d.update(0, stagePoint));

    if (event.type != "mouseout") {
      target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;
    } else {
      this.dispatchEvent(new Event(Event.MOUSE_LEAVE));
    }

    //-----------------------------------------------------------------

    if (_mouseTarget != target) {

      DisplayObject oldTarget = _mouseTarget;
      DisplayObject newTarget = target;
      List oldTargetList = [];
      List newTargetList = [];
      int commonCount = 0;

      for (DisplayObject p = oldTarget; p != null; p = p.parent) {
        oldTargetList.add(p);
      }

      for (DisplayObject p = newTarget; p != null; p = p.parent) {
        newTargetList.add(p);
      }

      for ( ; ; commonCount++) {
        if (commonCount == oldTargetList.length) break;
        if (commonCount == newTargetList.length) break;
        var ot = oldTargetList[oldTargetList.length - commonCount - 1];
        var nt = newTargetList[newTargetList.length - commonCount - 1];
        if (ot != nt) break;
      }

      if (oldTarget != null) {
        oldTarget.globalToLocal(stagePoint, localPoint);
        oldTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            event.altKey, event.ctrlKey, event.shiftKey,
            0.0, 0.0, mouseButton.buttonDown, 0));
      }

      for (int i = 0; i < oldTargetList.length - commonCount; i++) {
        DisplayObject target = oldTargetList[i];
        target.globalToLocal(stagePoint, localPoint);
        target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, false,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            event.altKey, event.ctrlKey, event.shiftKey,
            0.0, 0.0, mouseButton.buttonDown, 0));
      }

      for (int i = newTargetList.length - commonCount - 1; i >= 0; i--) {
        DisplayObject target = newTargetList[i];
        target.globalToLocal(stagePoint, localPoint);
        target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            event.altKey, event.ctrlKey, event.shiftKey,
            0.0, 0.0, mouseButton.buttonDown, 0));
      }

      if (newTarget != null) {
        newTarget.globalToLocal(stagePoint, localPoint);
        newTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            event.altKey, event.ctrlKey, event.shiftKey,
            0.0, 0.0, mouseButton.buttonDown, 0));
      }

      _mouseTarget = newTarget;
    }

    //-----------------------------------------------------------------

    _updateMouseCursor();

    //-----------------------------------------------------------------

    String mouseEventType = null;
    bool isClick = false;
    bool isDoubleClick = false;

    if (event.type == "mousedown") {
      _canvas.focus();
      mouseEventType = mouseButton.mouseDownEventType;

      if (target != mouseButton.target || time > mouseButton.clickTime + 500) {
        mouseButton.clickCount = 0;
      }

      mouseButton.buttonDown = true;
      mouseButton.target = target;
      mouseButton.clickTime = time;
      mouseButton.clickCount++;
    }

    if (event.type == "mouseup") {
      mouseEventType = mouseButton.mouseUpEventType;
      mouseButton.buttonDown = false;
      isClick = (mouseButton.target == target);
      isDoubleClick = isClick
          && mouseButton.clickCount.isEven
          && (time < mouseButton.clickTime + 500);
    }

    if (event.type == "mousemove") {
      mouseEventType = MouseEvent.MOUSE_MOVE;
    }

    if (event.type == "contextmenu") {
      mouseEventType = MouseEvent.CONTEXT_MENU;
    }

    //-----------------------------------------------------------------

    if (mouseEventType != null && target != null) {

      target.globalToLocal(stagePoint, localPoint);
      target.dispatchEvent(new MouseEvent(mouseEventType, true,
          localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
          event.altKey, event.ctrlKey, event.shiftKey,
          0.0, 0.0, mouseButton.buttonDown, mouseButton.clickCount));

      if (isClick) {

        mouseEventType = isDoubleClick && target.doubleClickEnabled
            ? mouseButton.mouseDoubleClickEventType
            : mouseButton.mouseClickEventType;

        target.dispatchEvent(new MouseEvent(mouseEventType, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            event.altKey, event.ctrlKey, event.shiftKey,
            0.0, 0.0, mouseButton.buttonDown, 0));
      }
    }
  }

  //----------------------------------------------------------------------------

  _onMouseWheelEvent(html.WheelEvent event) {

    var stagePoint = _clientTransformation.transformPoint(event.client);
    var localPoint = new Point<num>(0.0, 0.0);

    var target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;
    if (target == null) return;

    target.globalToLocal(stagePoint, localPoint);
    var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true,
        localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
        event.altKey, event.ctrlKey, event.shiftKey,
        event.deltaX, event.deltaY, false, 0);

    target.dispatchEvent(mouseEvent);
    if (mouseEvent.stopsPropagation) event.preventDefault();
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  List<StreamSubscription<html.TouchEvent>> _touchEventSubscriptions = [];

  _onMultitouchInputModeChanged(MultitouchInputMode inputMode) {

    _touchEventSubscriptions.forEach((s) => s.cancel());

    if (inputMode == MultitouchInputMode.TOUCH_POINT) {
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

  //----------------------------------------------------------------------------

  _onTouchEvent(html.TouchEvent event) {

    if (env.isCocoonJS) {

      var jsEvent = new JsObject.fromBrowserObject(event);
      var jsChangedTouches = new JsArray.from(jsEvent["changedTouches"]);
      var eventType = ensureString(jsEvent["type"]);

      jsEvent.callMethod("preventDefault");

      for(var changedTouch in jsChangedTouches) {
        var jsChangedTouch = new JsObject.fromBrowserObject(changedTouch);
        var identifier = ensureInt(jsChangedTouch["identifier"]);
        var clientX = ensureNum(jsChangedTouch["clientX"]);
        var clientY = ensureNum(jsChangedTouch["clientY"]);
        var client = new math.Point(clientX, clientY);
        _onTouchEventProcessor(eventType, identifier, client, false, false, false);
      }

    } else {

      event.preventDefault();

      var eventType = event.type;
      var altKey = event.altKey;
      var ctrlKey = event.ctrlKey;
      var shiftKey = event.shiftKey;

      for(var changedTouch in event.changedTouches) {
        var identifier = changedTouch.identifier;
        var client = changedTouch.client;
        _onTouchEventProcessor(eventType, identifier, client, altKey, ctrlKey, shiftKey);
      }
    }
  }

  //----------------------------------------------------------------------------

  _onTouchEventProcessor(String eventType, int identifier, math.Point client,
                         bool altKey, bool ctrlKey, bool shiftKey) {

    var stagePoint = _clientTransformation.transformPoint(client);
    var localPoint = new Point<num>(0.0, 0.0);
    var target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;

    var touchPoint = _touchPoints.putIfAbsent(identifier, () =>
        new _TouchPoint(target, _touchPoints.isEmpty));

    var touchPointID = touchPoint.touchPointID;
    var primaryTouchPoint = touchPoint.primaryTouchPoint;

    _drags.forEach((d) => d.update(touchPointID, stagePoint));

    if (touchPoint.currentTarget != target) {

      DisplayObject oldTarget = touchPoint.currentTarget;
      DisplayObject newTarget = target;
      List oldTargetList = [];
      List newTargetList = [];
      int commonCount = 0;

      for(DisplayObject p = oldTarget; p != null; p = p.parent) {
        oldTargetList.add(p);
      }

      for(DisplayObject p = newTarget; p != null; p = p.parent) {
        newTargetList.add(p);
      }

      for(;;commonCount++) {
        if (commonCount == oldTargetList.length) break;
        if (commonCount == newTargetList.length) break;
        var ot = oldTargetList[oldTargetList.length - commonCount - 1];
        var nt = newTargetList[newTargetList.length - commonCount - 1];
        if (ot != nt) break;
      }

      if (oldTarget != null) {
        oldTarget.globalToLocal(stagePoint, localPoint);
        oldTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));
      }

      for(int i = 0; i < oldTargetList.length - commonCount; i++) {
        DisplayObject target = oldTargetList[i];
        target.globalToLocal(stagePoint, localPoint);
        target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_ROLL_OUT, false,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));
      }

      for(int i = newTargetList.length - commonCount - 1; i >= 0; i--) {
        DisplayObject target = newTargetList[i];
        target.globalToLocal(stagePoint, localPoint);
        target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_ROLL_OVER, false,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));
      }

      if (newTarget != null) {
        newTarget.globalToLocal(stagePoint, localPoint);
        newTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OVER, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));
      }

      touchPoint.currentTarget = newTarget;
    }

    //-----------------------------------------------------------------

    String touchEventType = null;
    bool isTap = false;

    if (eventType == "touchstart") {
      _canvas.focus();
      _touchPoints[identifier] = touchPoint;
      touchEventType = TouchEvent.TOUCH_BEGIN;
    }

    if (eventType == "touchend") {
      _touchPoints.remove(identifier);
      touchEventType = TouchEvent.TOUCH_END;
      isTap = (touchPoint.target == target);
    }

    if (eventType == "touchcancel") {
      _touchPoints.remove(identifier);
      touchEventType = TouchEvent.TOUCH_CANCEL;
    }

    if (eventType == "touchmove") {
      touchEventType = TouchEvent.TOUCH_MOVE;
    }

    if (touchEventType != null && target != null) {

      target.globalToLocal(stagePoint, localPoint);
      target.dispatchEvent(new TouchEvent(touchEventType, true,
          localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
          altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));

      if (isTap) {
        target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_TAP, true,
            localPoint.x, localPoint.y, stagePoint.x, stagePoint.y,
            altKey, ctrlKey, shiftKey, touchPointID, primaryTouchPoint));
      }
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  _onKeyEvent(html.KeyboardEvent event) {

    if (event.keyCode == 8) event.preventDefault();
    if (_focus == null) return;

    if (event.type == "keypress") {

      var charCode = event.charCode;
      var keyCode = event.keyCode;
      if (keyCode == 13) charCode = 13;
      if (charCode == 0) return;

      var text = new String.fromCharCodes([charCode]);
      var textEvent = new TextEvent(TextEvent.TEXT_INPUT, true, text);

      _focus.dispatchEvent(textEvent);

      if (textEvent.stopsPropagation) event.preventDefault();

    } else {

      var keyLocation = KeyLocation.STANDARD;
      var keyboardEventType = "";

      if (event.type == "keyup") keyboardEventType = KeyboardEvent.KEY_UP;
      if (event.type == "keydown") keyboardEventType = KeyboardEvent.KEY_DOWN;
      if (event.keyLocation == html.KeyLocation.LEFT) keyLocation = KeyLocation.LEFT;
      if (event.keyLocation == html.KeyLocation.RIGHT) keyLocation = KeyLocation.RIGHT;
      if (event.keyLocation == html.KeyLocation.NUMPAD) keyLocation = KeyLocation.NUM_PAD;
      if (event.keyLocation == html.KeyLocation.JOYSTICK) keyLocation = KeyLocation.D_PAD;
      if (event.keyLocation == html.KeyLocation.MOBILE) keyLocation = KeyLocation.D_PAD;

      var keyboardEvent = new KeyboardEvent(keyboardEventType, true,
          event.keyCode, keyLocation,
          event.altKey, event.ctrlKey, event.shiftKey);

      _focus.dispatchEvent(keyboardEvent);

      if (keyboardEvent.stopsPropagation) event.preventDefault();
    }
  }

}
