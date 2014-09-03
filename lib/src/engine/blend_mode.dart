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
