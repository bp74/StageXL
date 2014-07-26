part of stagexl;

class BlendMode {
  final int _value;
  const BlendMode._internal(int value) : _value = value;

  static const NORMAL   = const BlendMode._internal(0);
  static const ADD      = const BlendMode._internal(1);
  static const MULTIPLY = const BlendMode._internal(2);
  static const SCREEN   = const BlendMode._internal(3);
  static const ERASE    = const BlendMode._internal(4);
  static const BELOW    = const BlendMode._internal(5);
  static const ABOVE    = const BlendMode._internal(6);
  static const NONE     = const BlendMode._internal(7);
}

/// The CompositeOperation is deprecated.
/// Please use BlendMode instead.
///
@deprecated
class CompositeOperation {
  static const String SOURCE_OVER       = "source-over";
  static const String SOURCE_IN         = "source-in";
  static const String SOURCE_OUT        = "source-out";
  static const String SOURCE_ATOP       = "source-atop";
  static const String DESTINATION_OVER  = "destination-over";
  static const String DESTINATION_IN    = "destination-in";
  static const String DESTINATION_OUT   = "destination-out";
  static const String DESTINATION_ATOP  = "destination-atop";
  static const String LIGHTER           = "lighter";
  static const String DARKER            = "darker";
  static const String COPY              = "copy";
  static const String XOR               = "xor";
}
