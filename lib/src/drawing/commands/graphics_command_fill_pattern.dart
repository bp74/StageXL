part of stagexl.drawing;

class _GraphicsCommandFillPattern extends GraphicsCommand {

  final GraphicsPattern pattern;

  _GraphicsCommandFillPattern(this.pattern);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillPattern(pattern);
  }
}
