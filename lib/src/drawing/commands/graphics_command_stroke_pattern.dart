part of stagexl.drawing.commands;

class GraphicsCommandStrokePattern extends GraphicsCommand {

  final GraphicsPattern pattern;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  GraphicsCommandStrokePattern(
      GraphicsPattern pattern,
      num lineWidth, String lineJoin, String lineCap) :

      this.pattern = pattern,
      this.lineWidth = lineWidth.toDouble(),
      this.lineJoin = lineJoin,
      this.lineCap = lineCap;

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokePattern(pattern, lineWidth, lineJoin, lineCap);
  }
}
