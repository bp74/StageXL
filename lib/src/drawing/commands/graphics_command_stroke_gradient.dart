part of stagexl.drawing;

class _GraphicsCommandStrokeGradient extends _GraphicsCommandStroke {

  final GraphicsGradient gradient;

  _GraphicsCommandStrokeGradient(
      GraphicsGradient gradient, num lineWidth, String lineJoin, String lineCap) :
        super (lineWidth, lineJoin, lineCap),  gradient = gradient;

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.strokeStyle = gradient.getCanvasGradient(context);
    context.lineWidth = lineWidth;
    context.lineJoin = lineJoin;
    context.lineCap = lineCap;
    context.stroke();
  }
}
