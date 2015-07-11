part of stagexl.drawing;

class _GraphicsCommandStrokePattern extends GraphicsCommand {

  final GraphicsPattern pattern;
  final double lineWidth;
  final String lineJoin;
  final String lineCap;

  _GraphicsCommandStrokePattern(
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
