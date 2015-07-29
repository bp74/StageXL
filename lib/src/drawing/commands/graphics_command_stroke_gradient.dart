part of stagexl.drawing.commands;

class GraphicsCommandStrokeGradient extends GraphicsCommand {

  final GraphicsGradient gradient;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  GraphicsCommandStrokeGradient(
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
