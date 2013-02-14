part of dartflash;

class MultitouchInputMode
{
  static const String GESTURE = "gesture";
  static const String NONE = "none";
  static const String TOUCH_POINT = "touchPoint";
}

class Multitouch
{
  static bool _initialized = false;
  static bool _supportsGestureEvents = false;
  static bool _supportsTouchEvents = false;
  static int _maxTouchPoints = 0;
  static List<String> _supportedGestures = [];
  static String _inputMode =  MultitouchInputMode.NONE;

  static StreamController<String> _inputModeChangedEvent = new StreamController<String>();
  static Stream<String> _onInputModeChanged = _inputModeChangedEvent.stream.asBroadcastStream();

  static _initialize()
  {
    if (_initialized == false)
    {
      _initialized = true;

      var ua = html.window.navigator.userAgent;

      // ToDo: feature detection using the userAgent is a bad idea in general.
      // Unfortunately there are no other good options right now :/
      // Maybe do some JS-interop?

      if (ua.contains("iPhone") || ua.contains("iPad") || ua.contains("iPod")) {
        _supportsTouchEvents = true;
        _maxTouchPoints = 10;
      }

      if (ua.contains("Android")) {
        _supportsTouchEvents = true;
        _maxTouchPoints = 10;
      }

      if (ua.contains("IEMobile")) {
        _supportsTouchEvents = true;
        _maxTouchPoints = 10;
      }
    }
  }

  //------------------------------------------------------------------

  static bool get supportsGestureEvents {
    _initialize();
    return _supportsGestureEvents;
  }

  static bool get supportsTouchEvents {
    _initialize();
    return _supportsTouchEvents;
  }

  static int get maxTouchPoints {
    _initialize();
    return _maxTouchPoints;
  }

  static List<String> get supportedGestures {
    _initialize();
    return _supportedGestures;
  }

  //------------------------------------------------------------------

  static String get inputMode {
    _initialize();
    return _inputMode;
  }

  static set inputMode(String value) {
    _initialize();
    _inputMode = value;
    _inputModeChangedEvent.add(_inputMode);
  }

}
