part of stagexl.drawing.commands;

class GraphicsCommandFillColor extends GraphicsCommand {

  final int color;

  GraphicsCommandFillColor(this.color);

  //---------------------------------------------------------------------------

  @override updateContext(GraphicsContext context) {
    context.fillColor(color);
  }
}
