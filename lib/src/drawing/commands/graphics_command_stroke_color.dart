part of stagexl.drawing;

class _GraphicsCommandStrokeColor extends _GraphicsCommandStroke {

  String _color;

  _GraphicsCommandStrokeColor(String color,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _color = color;
  }

  render(CanvasRenderingContext2D context) {
    context.strokeStyle = _color;
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;
    context.stroke();
  }
}