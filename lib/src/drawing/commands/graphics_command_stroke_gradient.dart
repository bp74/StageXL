part of stagexl.drawing;

class _GraphicsCommandStrokeGradient extends GraphicsCommand {

  final GraphicsGradient gradient;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  _GraphicsCommandStrokeGradient(
      GraphicsGradient gradient,
      num lineWidth, String lineJoin, String lineCap) :

      this.gradient = gradient,
      this.lineWidth = lineWidth.toDouble(),
      this.lineJoin = lineJoin,
      this.lineCap = lineCap;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeGradient(gradient, lineWidth, lineJoin, lineCap);
  }
}
