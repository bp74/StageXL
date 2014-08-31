library stagexl.ui.mouse;

import 'dart:async';
import 'dart:math';

class MouseCursor {
  static const String AUTO = "auto";
  static const String ARROW = "arrow";
  static const String BUTTON = "button";
  static const String HAND = "hand";
  static const String IBEAM = "ibeam";
  static const String WAIT = "wait";
}

class MouseCursorData {
  String url;
  Point<int> hotSpot;
  MouseCursorData(this.url, this.hotSpot);
}

class Mouse {

  static bool _cursorHidden = false;
  static String _cursorName = MouseCursor.AUTO;
  static Map<String, MouseCursorData> _cursorDatas = new Map<String, MouseCursorData>();

  static final _cursorChangedEvent = new StreamController<String>.broadcast();
  static Stream<String> onCursorChanged = _cursorChangedEvent.stream;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static String get cursor => _cursorName;

  static void set cursor(String cursorName) {
    _cursorName = cursorName;
    _cursorChangedEvent.add(cursorName);
  }

  //-------------------------------------------------------------------------------------------------

  static void registerCursor(String cursorName, MouseCursorData cursorData) {
    _cursorDatas[cursorName] = cursorData;
  }

  static void unregisterCursor(String cursorName) {
    _cursorDatas.remove(cursorName);
  }

  static void hide() {
    _cursorHidden = true;
    _cursorChangedEvent.add(_cursorName);
  }

  static void show() {
    _cursorHidden = false;
    _cursorChangedEvent.add(_cursorName);
  }

  //-------------------------------------------------------------------------------------------------

  static String getCursorStyle(String cursorName) {

    String style = "auto";

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

    return _cursorHidden ? "none": style;
  }

}
