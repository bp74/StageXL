part of dartflash;

class KeyboardEvent extends Event
{
  static const String KEY_DOWN = "keyDown";
  static const String KEY_UP = "keyUp";

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool _altKey;
  bool _ctrlKey;
  bool _shiftKey;
  bool _commandKey;     // Not supported
  bool _controlKey;     // Not supported

  int _charCode;
  int _keyCode;
  int _keyLocation;

  KeyboardEvent(String type, [bool bubbles = false]):super(type, bubbles)
  {
    _reset(type, bubbles);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _reset(String type, [bool bubbles = false])
  {
    super._reset(type, bubbles);

    _altKey = false;
    _ctrlKey = false;
    _shiftKey = false;
    _commandKey = false;
    _controlKey = false;

    _charCode = 0;
    _keyCode = 0;
    _keyLocation = 0;
  }

  //-------------------------------------------------------------------------------------------------
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
