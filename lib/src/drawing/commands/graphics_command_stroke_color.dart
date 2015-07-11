part of stagexl.drawing;

class _GraphicsCommandStrokeColor extends GraphicsCommand {

  final int color;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  _GraphicsCommandStrokeColor(int color, num lineWidth, String lineJoin, String lineCap) :
      color = color.toInt(),
      lineWidth = lineWidth.toDouble(),
      lineJoin = lineJoin,
      lineCap = lineCap;

  //---------------------------------------------------------------------------

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
