part of stagexl.drawing.commands;

class GraphicsCommandStrokePattern extends GraphicsCommandStroke {

  final GraphicsPattern pattern;

  GraphicsCommandStrokePattern(
      this.pattern, num width, String jointStyle, String capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokePattern(pattern, width, jointStyle, capsStyle);
  }
}
