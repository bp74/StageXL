part of stagexl;

class KeyboardEvent extends Event {

  static const String KEY_DOWN = "keyDown";
  static const String KEY_UP = "keyUp";

  //-----------------------------------------------------------------------------------------------

  final bool altKey, ctrlKey, shiftKey;
  final int charCode, keyCode, keyLocation;

  KeyboardEvent(String type, bool bubbles,
      this.charCode, this.keyCode, this.keyLocation,
      this.altKey, this.ctrlKey, this.shiftKey): super(type, bubbles);
}
