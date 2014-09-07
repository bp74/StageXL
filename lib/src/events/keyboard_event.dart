part of stagexl.events;

class KeyboardEvent extends Event {

  static const String KEY_DOWN = "keyDown";
  static const String KEY_UP = "keyUp";

  //-----------------------------------------------------------------------------------------------

  final int keyCode;
  final KeyLocation keyLocation;
  final bool altKey, ctrlKey, shiftKey;

  KeyboardEvent(String type, bool bubbles,
      this.keyCode, this.keyLocation,
      this.altKey, this.ctrlKey, this.shiftKey): super(type, bubbles);
}
