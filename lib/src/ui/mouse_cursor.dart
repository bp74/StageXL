part of stagexl;

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
