part of stagexl;

class Mouse {

  static String _customCursor = MouseCursor.AUTO;
  static bool _isCursorHidden = false;

  static Sprite _dragSprite = null;
  static Point<num> _dragSpriteCenter = null;
  static Rectangle<num> _dragSpriteBounds = null;

  static StreamController<String> _mouseCursorChangedEvent = new StreamController<String>();
  static Stream<String> _onMouseCursorChanged = _mouseCursorChangedEvent.stream.asBroadcastStream();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static String get cursor => _customCursor;

  static void set cursor(String value) {
    _customCursor = value;
    _mouseCursorChangedEvent.add("cursor");
  }

  //-------------------------------------------------------------------------------------------------

  static void hide() {
    _isCursorHidden = true;
    _mouseCursorChangedEvent.add("hide");
  }

  static void show() {
    _isCursorHidden = false;
    _mouseCursorChangedEvent.add("show");
  }

  //-------------------------------------------------------------------------------------------------

  static String _getCssStyle(String mouseCursor) {

    String cursor = mouseCursor;
    String style = "auto";

    if (_customCursor != MouseCursor.AUTO) {
      cursor = _customCursor;
    }

    switch(cursor) {
      case MouseCursor.AUTO: style = "auto"; break;
      case MouseCursor.ARROW: style = "default"; break;
      case MouseCursor.BUTTON: style = "pointer"; break;
      case MouseCursor.HAND: style = "move"; break;
      case MouseCursor.IBEAM: style = "text"; break;
      case MouseCursor.WAIT: style = "wait"; break;
    }

    // The cursor style "none" is not standardized, but works quite well.

    if (_isCursorHidden) {
      style = "none";
    }

    return style;
  }

}
