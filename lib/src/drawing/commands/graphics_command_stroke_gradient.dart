part of stagexl.drawing;

class _GraphicsCommandStrokeGradient extends GraphicsCommand {

  final GraphicsGradient gradient;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  _GraphicsCommandStrokeGradient(GraphicsGradient gradient, num lineWidth, String lineJoin, String lineCap) :
      gradient = gradient,
      lineWidth = lineWidth.toDouble(),
      lineJoin = lineJoin,
      lineCap = lineCap;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeGradient(gradient, lineWidth, lineJoin, lineCap);
  }

  /*
  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.strokeStyle = gradient.getCanvasGradient(context);
    context.lineWidth = lineWidth;
    context.lineJoin = lineJoin;
    context.lineCap = lineCap;
    context.stroke();
  }
  */
}
