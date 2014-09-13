library stagexl.ui.mouse;

import 'dart:async';
import 'dart:math';

class MouseCursor {
  static const String AUTO = "auto";
  static const String DEFAULT = "default";
  static const String POINTER = "pointer";
  static const String MOVE = "move";
  static const String CROSSHAIR = "crosshair";
  static const String TEXT = "text";
  static const String VERTICAL_TEXT = "vertical-text";
  static const String PROGRESS = "progress";
  static const String WAIT = "wait";
  static const String RESIZE_COLUMN = "col-resize";
  static const String RESIZE_ROW = "row-resize";
  static const String RESIZE_NORTH = "n-resize";
  static const String RESIZE_SOUTH = "s-resize";
  static const String RESIZE_EAST = "e-resize";
  static const String RESIZE_WEST = "w-resize";
  static const String RESIZE_NORTHWEST = "nw-resize";
  static const String RESIZE_NORTHEAST = "ne-resize";
  static const String RESIZE_SOUTHWEST = "sw-resize";
  static const String RESIZE_SOUTHEAST = "se-resize";
  static const String NOT_ALLOWED = "not-allowed";
  static const String NO_DROP = "no-drop";
  static const String ALL_SCROLL = "all-scroll";
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

    String style = cursorName;

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
