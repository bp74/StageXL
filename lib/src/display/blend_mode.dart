part of stagexl;

class BlendMode {
  static const String NORMAL   = "normal";
  static const String ADD      = "add";
  static const String MULTIPLY = "multiply";
  static const String SCREEN   = "screen";
  static const String ERASE    = "erase";
  static const String BELOW    = "below";
  static const String ABOVE    = "above";
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
