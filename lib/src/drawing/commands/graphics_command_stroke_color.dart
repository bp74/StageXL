part of stagexl.drawing.commands;

class GraphicsCommandStrokeColor extends GraphicsCommandStroke {

  final int color;

  GraphicsCommandStrokeColor(
      this.color, num width, String jointStyle, String capsStyle) :
        super(width.toDouble(), jointStyle, capsStyle);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.strokeColor(color, width, jointStyle, capsStyle);
  }
}
