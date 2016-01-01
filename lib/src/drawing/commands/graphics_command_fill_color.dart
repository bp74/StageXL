part of stagexl.drawing.commands;

class GraphicsCommandFillColor extends GraphicsCommandFill {

  final int color;

  GraphicsCommandFillColor(this.color);

  //---------------------------------------------------------------------------

  @override updateContext(GraphicsContext context) {
    context.fillColor(color);
  }
}
