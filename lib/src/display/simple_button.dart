part of stagexl.display;

enum SimpleButtonState { Up, Over, Down }

/// The SimpleButton class lets you control all instances of button symbols.

class SimpleButton extends InteractiveObject {

  /// Specifies a display object that is used as the visual object for the
  /// button up state — the state that the button is in when the pointer is not
  /// positioned over the button.

  DisplayObject upState;

  /// Specifies a display object that is used as the visual object for the
  /// button over state — the state that the button is in when the pointer is
  /// positioned over the button.

  DisplayObject overState;

  /// Specifies a display object that is used as the visual object for the
  /// button down state - the state that the button is in when the user
  /// selects the [hitTestState] object.

  DisplayObject downState;

  /// Specifies a display object that is used as the hit testing object for the
  /// button.
  ///
  /// For a basic button, set the [hitTestState] property to the same display
  /// object as the [overState] property. If you do not set the [hitTestState]
  /// property, the [SimpleButton] is inactive — it does not respond to user
  /// input events.

  DisplayObject hitTestState;

  /// Creates a new [SimpleButton] instance.
  ///
  /// Any or all of the display objects that represent the various button states
  /// can be set as parameters in the constructor.

  SimpleButton([this.upState, this.overState, this.downState, this.hitTestState]) {

    this.useHandCursor = true;

    this.onMouseOver.listen(_onMouseEvent);
    this.onMouseOut.listen(_onMouseEvent);
    this.onMouseDown.listen(_onMouseEvent);
    this.onMouseUp.listen(_onMouseEvent);

    this.onTouchOver.listen(_onTouchEvent);
    this.onTouchOut.listen(_onTouchEvent);
    this.onTouchBegin.listen(_onTouchEvent);
    this.onTouchEnd.listen(_onTouchEvent);
  }

  //---------------------------------------------------------------------------

  /// Specifies whether a button is enabled.
  ///
  /// When a button is disabled (the enabled property is set to false), the
  /// button is visible but cannot be clicked. The default value is true. This
  /// property is useful if you want to disable part of your navigation; for
  /// example, you might want to disable a button in the currently displayed
  /// page so that it can't be clicked and the page cannot be reloaded.
  ///
  /// Note: To prevent mouseClicks on a button, set both the enabled and
  /// [mouseEnabled] properties to false.

  bool get enabled => _enabled;

  void set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      _state = SimpleButtonState.Up;
    }
  }

  bool _enabled = true;

  /// The current state of the button (Up, Over, Down).
  ///
  /// This state is changing automatically if the mouse (or touch point) is
  /// over the button or the button is pressed.

  SimpleButtonState get state => _state;

  SimpleButtonState _state = SimpleButtonState.Up;

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    var displayObject = _getDisplayObject();
    return displayObject != null
        ? displayObject.boundsTransformed
        : super.bounds;
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {

    if (this.hitTestState == null) return null;

    Matrix matrix = hitTestState.transformationMatrix;

    num deltaX = localX - matrix.tx;
    num deltaY = localY - matrix.ty;
    num childX = (matrix.d * deltaX - matrix.c * deltaY) / matrix.det;
    num childY = (matrix.a * deltaY - matrix.b * deltaX) / matrix.det;

    return hitTestState.hitTestInput(childX, childY) != null ? this : null;
  }

  @override
  void render(RenderState renderState) {
    var displayObject = _getDisplayObject();
    if (displayObject != null) {
      renderState.renderObject(displayObject);
    }
  }

  //---------------------------------------------------------------------------

  DisplayObject _getDisplayObject() {
    switch(_state) {
      case SimpleButtonState.Up: return this.upState;
      case SimpleButtonState.Over: return this.overState;
      case SimpleButtonState.Down: return this.downState;
      default: return null;
    }
  }

  void _onMouseEvent(MouseEvent mouseEvent) {
    if (_enabled == false) {
      // don't change the state
    } if (mouseEvent.type == MouseEvent.MOUSE_OUT) {
      _state = SimpleButtonState.Up;
    } else if (mouseEvent.buttonDown) {
      _state = SimpleButtonState.Down;
    } else {
      _state = SimpleButtonState.Over;
    }
  }

  void _onTouchEvent(TouchEvent touchEvent) {
    if (_enabled == false) {
      // don't change the state
    } if (touchEvent.isPrimaryTouchPoint == false) {
      // don't change the state
    } else if (touchEvent.type == TouchEvent.TOUCH_OVER) {
      _state = SimpleButtonState.Down;
    } else if (touchEvent.type == TouchEvent.TOUCH_OUT) {
      _state = SimpleButtonState.Up;
    } else if (touchEvent.type == TouchEvent.TOUCH_BEGIN) {
      _state = SimpleButtonState.Down;
    } else if (touchEvent.type == TouchEvent.TOUCH_END) {
      _state = SimpleButtonState.Up;
    }
  }

}
