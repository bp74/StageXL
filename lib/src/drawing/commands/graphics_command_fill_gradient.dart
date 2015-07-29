part of stagexl.drawing.commands;

class GraphicsCommandFillGradient extends GraphicsCommand {

  final GraphicsGradient gradient;

  GraphicsCommandFillGradient(this.gradient);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillGradient(gradient);
  }
}
