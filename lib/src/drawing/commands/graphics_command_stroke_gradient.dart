part of stagexl.drawing;

class GraphicsCommandStrokeGradient extends GraphicsCommandStroke {

  final GraphicsGradient gradient;

  GraphicsCommandStrokeGradient(
      this.gradient, num width, JointStyle jointStyle, CapsStyle capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeGradient(gradient, width, jointStyle, capsStyle);
  }
}
