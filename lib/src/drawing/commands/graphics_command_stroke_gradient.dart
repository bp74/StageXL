part of stagexl.drawing;

class _GraphicsCommandStrokeGradient extends _GraphicsCommandStroke {

  GraphicsGradient _gradient;

  _GraphicsCommandStrokeGradient(GraphicsGradient gradient,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _gradient = gradient;
  }

  render(CanvasRenderingContext2D context) {
    context.strokeStyle = _gradient.getCanvasGradient(context);
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;
    context.stroke();
  }
}