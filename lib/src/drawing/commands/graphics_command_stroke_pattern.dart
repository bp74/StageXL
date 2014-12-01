part of stagexl.drawing;

class _GraphicsCommandStrokePattern extends _GraphicsCommandStroke {

  GraphicsPattern _pattern;

  _GraphicsCommandStrokePattern(GraphicsPattern pattern,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _pattern = pattern;
  }

  //---------------------------------------------------------------------------

  @override
  void render(CanvasRenderingContext2D context) {
    context.strokeStyle = _pattern.getCanvasPattern(context);
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;

    var matrix = _pattern.matrix;

    if (matrix != null) {
      context.save();
      context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.stroke();
      context.restore();
    } else {
      context.stroke();
    }
  }
}
