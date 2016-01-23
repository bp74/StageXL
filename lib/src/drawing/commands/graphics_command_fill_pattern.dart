part of stagexl.drawing;

class GraphicsCommandFillPattern extends GraphicsCommandFill {

  final GraphicsPattern pattern;

  GraphicsCommandFillPattern(this.pattern);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillPattern(pattern);
  }
}
