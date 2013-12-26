part of stagexl;

class KeyboardEvent extends Event {

  static const String KEY_DOWN = "keyDown";
  static const String KEY_UP = "keyUp";

  //-------------------------------------------------------------------------------------------------

  bool _altKey = false;
  bool _ctrlKey = false;
  bool _shiftKey = false;
  bool _commandKey = false;     // Not supported
  bool _controlKey = false;     // Not supported

  int _charCode = 0;
  int _keyCode = 0;
  int _keyLocation = 0;

  KeyboardEvent(String type, [bool bubbles = false]) : super(type, bubbles);

  //-------------------------------------------------------------------------------------------------

  bool get altKey => _altKey;
  bool get ctrlKey => _ctrlKey;
  bool get shiftKey => _shiftKey;
  bool get commandKey => _commandKey;
  bool get controlKey => _controlKey;

  int get charCode => _charCode;
  int get keyCode => _keyCode;
  int get keyLocation => _keyLocation;
}
