part of stagexl.drawing;

class _GraphicsCommandFillPattern extends _GraphicsCommandFill {

  GraphicsPattern _pattern;

  _GraphicsCommandFillPattern(GraphicsPattern pattern) {
    _pattern = pattern;
  }

  render(CanvasRenderingContext2D context) {

    context.fillStyle = _pattern.getCanvasPattern(context);
    var matrix = _pattern.matrix;

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
