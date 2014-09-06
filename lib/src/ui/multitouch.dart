library stagexl.ui.multitouch;

import 'dart:async';
import 'dart:html' as html;

/// The input modes for touch screen devices.
///
class MultitouchInputMode {
  final String name;
  const MultitouchInputMode(this.name);

  static const MultitouchInputMode GESTURE = const MultitouchInputMode("GESTURE");
  static const MultitouchInputMode NONE = const MultitouchInputMode("NONE");
  static const MultitouchInputMode TOUCH_POINT = const MultitouchInputMode("TOUCH_POINT");
}

/// The [Multitouch] class is used opt-in for multi touch support in your
/// application. It also provides an easy way to check if the current device
/// supports multi touch or not.
///
/// Example:
///
///     if (Multitouch.supportsTouchEvents) {
///       Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
///     }
///
///     var sprite = new Sprite();
///     sprite.onMouseDown.listen(_onMouseDown);
///     sprite.onTouchBegin.listen(_onTouchBegin);
///
class Multitouch {

  static bool supportsGestureEvents = false;
  static bool supportsTouchEvents = _checkTouchEvents();
  static List<String> supportedGestures = [];

  static bool _initialized = false;
  static MultitouchInputMode _inputMode =  MultitouchInputMode.NONE;

  static final _inputModeChangedEvent = new StreamController<MultitouchInputMode>.broadcast();
  static Stream<MultitouchInputMode> onInputModeChanged = _inputModeChangedEvent.stream;

  //------------------------------------------------------------------

  static int get maxTouchPoints => supportsTouchEvents ? 10 : 0;

  static MultitouchInputMode get inputMode => _inputMode;

  static set inputMode(MultitouchInputMode value) {
    _inputMode = value;
    _inputModeChangedEvent.add(value);
  }

  //------------------------------------------------------------------

  static bool _checkTouchEvents() {
    try {
      return html.TouchEvent.supported;
    } catch (e) {
      return false;
    }
  }

}
