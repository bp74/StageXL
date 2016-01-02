part of stagexl.drawing.commands;

class GraphicsCommandStrokePattern extends GraphicsCommandStroke {

  final GraphicsPattern pattern;

  GraphicsCommandStrokePattern(
      this.pattern, num width, JointStyle jointStyle, CapsStyle capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokePattern(pattern, width, jointStyle, capsStyle);
  }
}
