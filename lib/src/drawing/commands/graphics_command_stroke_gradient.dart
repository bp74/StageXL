part of stagexl.drawing.commands;

class GraphicsCommandStrokeGradient extends GraphicsCommandStroke {

  final GraphicsGradient gradient;

  GraphicsCommandStrokeGradient(
      this.gradient, num width, String jointStyle, String capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeGradient(gradient, width, jointStyle, capsStyle);
  }
}
