library stagexl.ui.multitouch;

import 'dart:async';
import 'dart:html' as html;

class MultitouchInputMode {
  final String name;
  const MultitouchInputMode(this.name);

  static const MultitouchInputMode GESTURE = const MultitouchInputMode("GESTURE");
  static const MultitouchInputMode NONE = const MultitouchInputMode("NONE");
  static const MultitouchInputMode TOUCH_POINT = const MultitouchInputMode("TOUCH_POINT");
}

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
