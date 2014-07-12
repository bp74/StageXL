part of stagexl;

class MultitouchInputMode {

  static const String GESTURE = "gesture";
  static const String NONE = "none";
  static const String TOUCH_POINT = "touchPoint";
}

class Multitouch {

  static bool _initialized = false;
  static bool _supportsGestureEvents = false;
  static bool _supportsTouchEvents = _checkTouchEvents;

  static List<String> _supportedGestures = [];
  static String _inputMode =  MultitouchInputMode.NONE;

  static StreamController<String> _inputModeChangedEvent = new StreamController<String>();
  static Stream<String> _onInputModeChanged = _inputModeChangedEvent.stream.asBroadcastStream();

  //------------------------------------------------------------------

  static bool get supportsGestureEvents => _supportsGestureEvents;
  static bool get supportsTouchEvents => _supportsTouchEvents;
  static List<String> get supportedGestures => _supportedGestures;

  static int get maxTouchPoints => _supportsTouchEvents ? 10 : 0;

  static String get inputMode => _inputMode;

  static set inputMode(String value) {
    _inputMode = value;
    _inputModeChangedEvent.add(_inputMode);
  }

  //------------------------------------------------------------------

  static bool get _checkTouchEvents {
    try {
      return html.TouchEvent.supported;
    } catch (e) {
      return false;
    }
  }

}
