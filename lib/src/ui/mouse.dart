part of stagexl;

class Mouse {

  static bool _cursorHidden = false;
  static String _cursorName = MouseCursor.AUTO;
  static Map<String, MouseCursorData> _cursorDatas = new Map<String, MouseCursorData>();

  static Sprite _dragSprite = null;
  static Point<num> _dragSpriteCenter = null;
  static Rectangle<num> _dragSpriteBounds = null;

  static StreamController<String> _mouseCursorChangedEvent = new StreamController<String>();
  static Stream<String> _onMouseCursorChanged = _mouseCursorChangedEvent.stream.asBroadcastStream();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static String get cursor => _cursorName;

  static void set cursor(String value) {
    _cursorName = value;
    _mouseCursorChangedEvent.add("cursor");
  }

  //-------------------------------------------------------------------------------------------------

  static void registerCursor(String cursorName, MouseCursorData cursorData) {
    _cursorDatas[cursorName] = cursorData;
    _mouseCursorChangedEvent.add("registerCursor");
  }

  static void unregisterCursor(String cursorName) {
    _cursorDatas.remove(cursorName);
    _mouseCursorChangedEvent.add("unregisterCursor");
  }

  //-------------------------------------------------------------------------------------------------

  static void hide() {
    _cursorHidden = true;
    _mouseCursorChangedEvent.add("hide");
  }

  static void show() {
    _cursorHidden = false;
    _mouseCursorChangedEvent.add("show");
  }

  //-------------------------------------------------------------------------------------------------

  static String _getCssStyle(String cursorName) {

    String style = "auto";

    if (_cursorName != MouseCursor.AUTO) {
      cursorName = _cursorName;
    }

    switch(cursorName) {
      case MouseCursor.AUTO: style = "auto"; break;
      case MouseCursor.ARROW: style = "default"; break;
      case MouseCursor.BUTTON: style = "pointer"; break;
      case MouseCursor.HAND: style = "move"; break;
      case MouseCursor.IBEAM: style = "text"; break;
      case MouseCursor.WAIT: style = "wait"; break;
    }

    if (_cursorDatas.containsKey(cursorName)) {
      var cursorData = _cursorDatas[cursorName];
      var cursorDataUrl = cursorData.url;
      var cursorDataX = cursorData.hotSpot.x;
      var cursorDataY = cursorData.hotSpot.y;
      style = "url('$cursorDataUrl') $cursorDataX $cursorDataY, $style";
    }

    if (_cursorHidden) {
      style = "none";
    }

    return style;
  }

}
