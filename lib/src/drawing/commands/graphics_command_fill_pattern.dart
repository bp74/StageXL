part of stagexl.drawing;

class _GraphicsCommandFillPattern extends _GraphicsCommandFill {

  final GraphicsPattern pattern;

  _GraphicsCommandFillPattern(this.pattern);

  @override
  void drawCanvas(CanvasRenderingContext2D context) {

    context.fillStyle = pattern.getCanvasPattern(context);
    var matrix = pattern.matrix;

    if (matrix != null) {
      context.save();
      context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.fill();
      context.restore();
    } else {
      context.fill();
    }
  }
}
