part of stagexl.events;

/// An [Event] that is dispatched in response to user input through a keyboard. 
/// 
/// There are two types of keyboard events:
/// 
/// * [KeyboardEvent.KEY_DOWN]
/// * [KeyboardEvent.KEY_UP]
class KeyboardEvent extends Event {

  static const String KEY_DOWN = "keyDown";
  static const String KEY_UP = "keyUp";

  //----------------------------------------------------------------------------

  /// The key code value of the key pressed or released.

  final int keyCode;
  
  /// Indicates the location of the key on the keyboard. 
  /// 
  /// This is useful for differentiating keys that appear more than once on a 
  /// keyboard. For example, you can differentiate between the left and right 
  /// Shift keys by the value of this property: 
  /// 
  /// * [KeyLocation.LEFT] for the left and 
  /// * [KeyLocation.RIGHT] for the right. 
  /// 
  /// Another example is differentiating between number keys pressed on the 
  /// standard keyboard ([KeyLocation.STANDARD]) versus the numeric keypad 
  /// ([KeyLocation.NUM_PAD]).

  final KeyLocation keyLocation;
  
  /// Indicates whether the Alt key is active (true) or inactive (false) on 
  /// Windows; indicates whether the Option key is active on Mac OS.

  final bool altKey;
  
  /// Indicates whether the Ctrl key is active (true) or inactive (false).

  final bool ctrlKey;
  
  /// Indicates whether the Shift key is active (true) or inactive (false).

  final bool shiftKey;

  /// Creates a new [KeyboardEvent].

  KeyboardEvent(String type, bool bubbles,
      this.keyCode, this.keyLocation,
      this.altKey, this.ctrlKey, this.shiftKey): super(type, bubbles);

  //---------------------------------------------------------------------------

  bool _isDefaultPrevented = false;

  void preventDefault() {
    _isDefaultPrevented = true;
  }

  bool get isDefaultPrevented => _isDefaultPrevented;
}
