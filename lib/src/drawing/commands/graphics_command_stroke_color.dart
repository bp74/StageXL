part of stagexl.drawing;

class _GraphicsCommandStrokeColor extends _GraphicsCommandStroke {

  final String color;

  _GraphicsCommandStrokeColor(
      String color, num lineWidth, String lineJoin, String lineCap) :
        super (lineWidth, lineJoin, lineCap), color = color;

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.strokeStyle = color;
    context.lineWidth = lineWidth;
    context.lineJoin = lineJoin;
    context.lineCap = lineCap;
    context.stroke();
  }
}
