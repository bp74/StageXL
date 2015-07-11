part of stagexl.drawing;

class _GraphicsCommandStrokeColor extends GraphicsCommandStroke {

  final int color;

  _GraphicsCommandStrokeColor(
      int color, num lineWidth, String lineJoin, String lineCap) :
        super (lineWidth, lineJoin, lineCap), color = color;

  @override
  void updateContext(GraphicsContext context) {
    context.strokeColor(color, lineWidth, lineJoin, lineCap);
  }

/*
  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.strokeStyle = color2rgba(color);
    context.lineWidth = lineWidth;
    context.lineJoin = lineJoin;
    context.lineCap = lineCap;
    context.stroke();
  }
  */
}
