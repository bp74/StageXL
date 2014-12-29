part of stagexl.events;

/// Defines the standard key locations returned by 
/// [KeyboardEvent.getKeyLocation].
class KeyLocation {

  final int index;
  const KeyLocation._(this.index);

  /// The event key is not distinguished as the left or right version
  /// of the key, and did not originate from the numeric keypad (or did not
  /// originate with a virtual key corresponding to the numeric keypad).
  static const KeyLocation STANDARD = const KeyLocation._(0);

  /// The event key is in the left key location.
  static const KeyLocation LEFT = const KeyLocation._(1);
  
  /// The event key is in the right key location.
  static const KeyLocation RIGHT = const KeyLocation._(2);
  
  /// The event key originated on the numeric keypad or with a virtual key
  /// corresponding to the numeric keypad.
  static const KeyLocation NUM_PAD = const KeyLocation._(3);
  
  /// The event key originated on a directional pad of input device:
  /// 
  /// * On a mobile device either on a physical keypad or a virtual keyboard.
  /// * On a game controller or a joystick on a mobile device.
  static const KeyLocation D_PAD = const KeyLocation._(4);
}
