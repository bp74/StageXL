part of stagexl.drawing.commands;

class GraphicsCommandFillPattern extends GraphicsCommand {

  final GraphicsPattern pattern;

  GraphicsCommandFillPattern(this.pattern);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillPattern(pattern);
  }
}
