part of dartflash;

class MultitouchInputMode
{
  static const String GESTURE = "gesture";
  static const String NONE = "none";
  static const String TOUCH_POINT = "touchPoint";
}

class Multitouch
{
  static String inputMode = MultitouchInputMode.NONE;
  static int maxTouchPoints = 0;
  static List<String> supportedGestures = [];
  static bool supportsGestureEvents = false;
  static bool supportsTouchEvents = false;
}
