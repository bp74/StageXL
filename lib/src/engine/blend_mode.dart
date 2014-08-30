part of stagexl.engine;

class BlendMode {

  final int srcFactor;
  final int dstFactor;
  final String compositeOperation;

  const BlendMode(this.srcFactor, this.dstFactor, this.compositeOperation);

  static const NORMAL   = const BlendMode(gl.ONE, gl.ONE_MINUS_SRC_ALPHA, "source-over");
  static const ADD      = const BlendMode(gl.ONE, gl.ONE, "lighter");
  static const MULTIPLY = const BlendMode(gl.DST_COLOR, gl.ONE_MINUS_SRC_ALPHA, "multiply");
  static const SCREEN   = const BlendMode(gl.ONE, gl.ONE_MINUS_SRC_COLOR, "screen");
  static const ERASE    = const BlendMode(gl.ZERO, gl.ONE_MINUS_SRC_ALPHA, "destination-out");
  static const BELOW    = const BlendMode(gl.ONE_MINUS_DST_ALPHA, gl.ONE, "destination-over");
  static const ABOVE    = const BlendMode(gl.DST_ALPHA, gl.ONE_MINUS_SRC_ALPHA, "source-atop");
  static const NONE     = const BlendMode(gl.ONE, gl.ZERO, "source-over");
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
