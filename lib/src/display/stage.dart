part of stagexl;

/**
 * The StageScaleMode defines how the Stage is scaled inside of the Canvas.
 */
class StageScaleMode {
  static const String EXACT_FIT = "exactFit";
  static const String NO_BORDER = "noBorder";
  static const String NO_SCALE = "noScale";
  static const String SHOW_ALL = "showAll";
}

/**
 * The StageAlign defines how the content of the Stage is aligned inside
 * of the Canvas. The setting controls where the origin (point 0,0) of the
 * Stage will be placed on the Canvas.
 */
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

/**
 * The StageRenderMode defines how often the Stage is renderes by
 * the [RenderLoop] where the Stage is attached to.
 */
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

/**
 * The Stage is the drawing area wher all display objects are rendered to.
 * Place a Canvas element to your HTML and use the Stage to wrap all the
 * rendering functions to this Canvas element.
 *
 * Example:
 *
 * HTML: <canvas id="stage" width="800" height="600"></canvas>
 * Dart: var stage = new Stage(querySelector("#stage"));
 */
class Stage extends DisplayObjectContainer {

  static bool autoHiDpi = _autoHiDpi;
  static bool get isMobile => _isMobile;
  static num get devicePixelRatio => _devicePixelRatio;

  CanvasElement _canvas;
  RenderContext _renderContext;

  int _sourceWidth = 0;
  int _sourceHeight = 0;
  int _frameRate = 30;
  int _canvasWidth = -1;
  int _canvasHeight = -1;
  Rectangle _contentRectangle = new Rectangle.zero();

  Matrix _clientTransformation = new Matrix.fromIdentity();
  Matrix _stageTransformation = new Matrix.fromIdentity();
  RenderLoop _renderLoop = null;
  Juggler _juggler = new Juggler();

  InteractiveObject _focus = null;
  RenderState _renderState = null;
  String _stageRenderMode = StageRenderMode.AUTO;
  String _stageScaleMode = StageScaleMode.SHOW_ALL;
  String _stageAlign = StageAlign.NONE;

  String _mouseCursor = MouseCursor.ARROW;
  Point _mousePosition = new Point.zero();
  InteractiveObject _mouseTarget = null;

  Map<int, _Touch> _touches = new Map<int, _Touch>();
  List<_MouseButton> _mouseButtons = [
    new _MouseButton(MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_UP, MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK),
    new _MouseButton(MouseEvent.MIDDLE_MOUSE_DOWN, MouseEvent.MIDDLE_MOUSE_UP, MouseEvent.MIDDLE_CLICK, MouseEvent.MIDDLE_CLICK),
    new _MouseButton(MouseEvent.RIGHT_MOUSE_DOWN, MouseEvent.RIGHT_MOUSE_UP, MouseEvent.RIGHT_CLICK, MouseEvent.RIGHT_CLICK)];

  //-------------------------------------------------------------------------------------------------

  static const EventStreamProvider<Event> resizeEvent = const EventStreamProvider<Event>(Event.RESIZE);
  EventStream<Event> get onResize => Stage.resizeEvent.forTarget(this);

  //-------------------------------------------------------------------------------------------------

  Stage(CanvasElement canvas, {int width, int height,
    bool webGL: false, int frameRate: 30, int color: Color.White}) {

    if (canvas is! CanvasElement) {
      throw new ArgumentError("The canvas argument is not a CanvasElement");
    }

    _canvas = canvas;

    if (canvas.tabIndex == -1) canvas.tabIndex = 0;
    if (canvas.style.outline == "") canvas.style.outline = "none";

    _sourceWidth = _ensureInt((width != null) ? width : canvas.width);
    _sourceHeight = _ensureInt((width != null) ? height : canvas.height);
    _frameRate = _ensureInt((frameRate != null) ? frameRate : 30);

    if (webGL && gl.RenderingContext.supported) {
      try {
        _renderContext = new RenderContextWebGL(canvas, color);
      } catch(e) {
        _renderContext = new RenderContextCanvas(canvas, color);
      }
    } else {
      _renderContext = new RenderContextCanvas(canvas, color);
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

    Mouse._onMouseCursorChanged.listen(_onMouseCursorChanged);
    Multitouch._onInputModeChanged.listen(_onMultitouchInputModeChanged);

    _onMultitouchInputModeChanged(null);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  /**
   * Gets the original source width of the Stage as defined in the constructor.
   */
  int get sourceWidth => _sourceWidth;

  /**
   * Gets the original source height of the Stage as defined in the constructor.
   */
  int get sourceHeight => _sourceHeight;

  /**
   * Gets the current width of the Stage in pixels on the screen.
   */
  int get stageWidth => _canvasWidth;

  /**
   * Gets the current height of the Stage in pixels on the screen.
   */
  int get stageHeight => _canvasHeight;

  /**
   * Gets the available content area on the stage. The value of this rectangle
   * changes with the scaleMode and the alignment of the stage, as well as the size
   * of the underlying Canvas element.
   */
  Rectangle get contentRectangle => _contentRectangle.clone();

  /**
   * Gets the underlying render engine used to draw the pixels to the screen.
   * The returned string is defined in [RenderEngine] and is either "WebGL"
   * or "Canvas2D".
   */
  String get renderEngine => _renderContext.renderEngine;

  /**
   * Gets the [RenderLoop] where this Stage was added to, or
   * NULL in case this Stage is not added to a [RenderLoop].
   */
  RenderLoop get renderLoop => _renderLoop;

  /**
   * Gets the [Juggler] of this Stage. The Juggler is driven by the
   * [RenderLoop] where this Stage is added to. If this Stage is not
   * added to a RenderLoop, the [Juggler] will not advance in time.
   */
  Juggler get juggler => _juggler;

  /**
   * Gets the last known mouse position in Stage coordinates.
   */
  Point get mousePosition => _mousePosition;

  /**
   * Gets and sets the default frame rate for MovieClips. This value has no
   * impact on the frame rate of the Stage itself.
   */
  int get frameRate => _frameRate;

  set frameRate(int value) {
    _frameRate = value;
  }

  /**
   * Gets and sets the [InteractiveObject] (a DisplayObject which can
   * receive user input like mouse, touch or keyboard).
   */
  InteractiveObject get focus => _focus;

  set focus(InteractiveObject value) {
    _focus = value;
  }

  /**
   * Gets and sets the render mode of this Stage. You can choose between
   * three different modes defined in [StageRenderMode].
   */
  String get renderMode => _stageRenderMode;

  set renderMode(String value) {
    _stageRenderMode = value;
  }

  /**
   * Gets and sets the scale mode of this Stage. You can choose between
   * four dfferent modes defined in [StageScaleMode].
   */
  String get scaleMode => _stageScaleMode;

  set scaleMode(String value) {
    _stageScaleMode = value;
    _updateCanvasSize();
  }

  /**
   * Gets and sets the alignment of this Stage inside of the Canvas element.
   * You can choose between nine different align modes defined in [StageAlign].
   */
  String get align => _stageAlign;
  set align(String value) {
    _stageAlign = value;
    _updateCanvasSize();
  }

  /**
   * Calling this method will cause an [RenderEvent] to be fired right before
   * the next frame will be rendered by the render loop. To receive the render
   * event attach a listener to [DisplayObject.onRender].
   */
  invalidate() {
    if (_renderLoop != null) {
      _renderLoop.invalidate();
    }
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

  /**
   * This method is called by the [RenderLoop] where this Stage is added to.
   * If this Stage is not added to a [RenderLoop] you could call this method
   * on your own and therefore get full control of the rendering of this Stage.
   */
  materialize(num currentTime, num deltaTime) {

    if (_stageRenderMode == StageRenderMode.AUTO || _stageRenderMode == StageRenderMode.ONCE) {

      _updateCanvasSize();

      _renderState.reset(_stageTransformation, currentTime, deltaTime);
      render(_renderState);
      _renderState.flush();

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
    var sourceWidth = _sourceWidth;
    var sourceHeight = _sourceHeight;

    if (clientWidth is! num) throw "dart2js_hint";
    if (clientHeight is! num) throw "dart2js_hint";
    if (sourceWidth is! num) throw "dart2js_hint";
    if (sourceHeight is! num) throw "dart2js_hint";

    if (clientWidth == 0 || clientHeight == 0) return;

    //----------------------------

    var scaleX = 1.0;
    var scaleY = 1.0;
    var pivotX = 0.0;
    var pivotY = 0.0;
    var ratioWidth = clientWidth / sourceWidth;
    var ratioHeight = clientHeight / sourceHeight;

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

    switch(_stageAlign) {
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

    switch(_stageAlign) {
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
    contentRectangle.x = - pivotX / scaleX;
    contentRectangle.y = - pivotY / scaleY;
    contentRectangle.width = clientWidth / scaleX;
    contentRectangle.height = clientHeight / scaleY;

    var pixelRatio = (Stage.autoHiDpi ? _devicePixelRatio : 1.0) / _backingStorePixelRatio;

    // stage to canvas coordinate transformation
    _stageTransformation.setTo(scaleX, 0.0, 0.0, scaleY, pivotX, pivotY);
    _stageTransformation.scale(pixelRatio, pixelRatio);

    // client to stage coordinate transformation
    _clientTransformation.setTo(1.0, 0.0, 0.0, 1.0, - clientLeft - pivotX, - clientTop - pivotY);
    _clientTransformation.scale(1.0 / scaleX, 1.0 / scaleY);

    if (_canvasWidth != clientWidth || _canvasHeight != clientHeight) {
      _canvasWidth = clientWidth;
      _canvasHeight = clientHeight;
      _canvas.width = (_canvasWidth * pixelRatio).round();
      _canvas.height = (_canvasHeight * pixelRatio).round();

      // update hi-dpi canvas style size if client size has changed
      if (_canvas.clientWidth != clientWidth || _canvas.clientHeight != clientHeight) {
        _canvas.style.width = "${clientWidth}px";
        _canvas.style.height = "${clientHeight}px";
      }

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

    if (Mouse._dragSprite != null) {
      Mouse._dragSprite._updateDrag();
    }

    if (event.type != "mouseout") {
      target = hitTestInput(stagePoint.x, stagePoint.y) as InteractiveObject;
    }

    //-----------------------------------------------------------------

    var mouseCursor = MouseCursor.ARROW;

    if (target is Sprite && (target as Sprite).useHandCursor) {
      mouseCursor = MouseCursor.BUTTON;
    }

    if (target is SimpleButton && (target as SimpleButton).useHandCursor) {
      mouseCursor = MouseCursor.BUTTON;
    }

    if (target is TextField && (target as TextField).type == TextFieldType.INPUT) {
      mouseCursor = MouseCursor.IBEAM;
    }

    if (_mouseCursor != mouseCursor) {
      _mouseCursor = mouseCursor;
      _canvas.style.cursor = Mouse._getCssStyle(mouseCursor);
    }

    //-----------------------------------------------------------------

    if (_mouseTarget != target) {

      DisplayObject oldTarget = _mouseTarget;
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
        oldTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true)
            .._localPoint = oldTarget.globalToLocal(stagePoint)
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);
      }

      for(int i = 0; i < oldTargetList.length - commonCount; i++) {
        DisplayObject target = oldTargetList[i];
        target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, false)
            .._localPoint = target.globalToLocal(stagePoint)
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);
      }

      for(int i = newTargetList.length - commonCount - 1; i >= 0; i--) {
        DisplayObject target = newTargetList[i];
        target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false)
            .._localPoint = target.globalToLocal(stagePoint)
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);
      }

      if (newTarget != null) {
        newTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true)
            .._localPoint = newTarget.globalToLocal(stagePoint)
            .._stagePoint = stagePoint
            .._buttonDown = mouseButton.buttonDown);
      }

      _mouseTarget = newTarget;
    }

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

      localPoint = target.globalToLocal(stagePoint);

      target.dispatchEvent(new MouseEvent(mouseEventType, true)
          .._localPoint = localPoint
          .._stagePoint = stagePoint
          .._buttonDown = mouseButton.buttonDown
          .._clickCount = mouseButton.clickCount);

      if (isClick) {

        if (isDoubleClick && target.doubleClickEnabled) {

          target.dispatchEvent(new MouseEvent(mouseButton.mouseDoubleClickEventType, true)
              .._localPoint = localPoint
              .._stagePoint = stagePoint
              .._buttonDown = mouseButton.buttonDown);

        } else {

          target.dispatchEvent(new MouseEvent(mouseButton.mouseClickEventType, true)
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
      var mouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true)
          .._localPoint = target.globalToLocal(stagePoint)
          .._stagePoint = stagePoint
          .._deltaX = event.deltaX
          .._deltaY = event.deltaY;

      target.dispatchEvent(mouseEvent);
      if (mouseEvent.stopsPropagation) event.preventDefault();
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  List<StreamSubscription<html.TouchEvent>> _touchEventSubscriptions = [];

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

        touch.target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, true)
          .._localPoint = (touch.target.stage != null)
              ? touch.target.globalToLocal(stagePoint) : new Point.zero()
          .._stagePoint = stagePoint
          .._touchPointID = touch.touchPointID
          .._isPrimaryTouchPoint = touch.primaryTouchPoint);

        touch.target = null;
      }

      if (target != null && target != touch.target) {

        target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OVER, true)
          .._localPoint = target.globalToLocal(stagePoint)
          .._stagePoint = stagePoint
          .._touchPointID = touch.touchPointID
          .._isPrimaryTouchPoint = touch.primaryTouchPoint);

        touch.target = target;
      }

      //-----------------------------------------------------------------

      String touchEventType = null;

      if (event.type == "touchstart") {
        _canvas.focus();
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

        target.dispatchEvent(new TouchEvent(touchEventType, true)
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

    if (event.keyCode == 8) event.preventDefault();
    if (_focus == null) return;

    if (event.type == "keypress") {

      var charCode = event.charCode;
      var keyCode = event.keyCode;
      if (keyCode == 13) charCode = 13;
      if (charCode == 0) return;

      _focus.dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true)
          .._text = new String.fromCharCodes([charCode]));

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

      var keyboardEvent = new KeyboardEvent(keyboardEventType, true)
          .._altKey = event.altKey
          .._ctrlKey = event.ctrlKey
          .._shiftKey = event.shiftKey
          .._charCode = event.charCode
          .._keyCode = event.keyCode
          .._keyLocation = keyLocation;

      _focus.dispatchEvent(keyboardEvent);

      if (keyboardEvent.stopsPropagation) event.preventDefault();
    }
  }

}
