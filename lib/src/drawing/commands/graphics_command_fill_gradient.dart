part of stagexl.drawing;

class GraphicsCommandFillGradient extends GraphicsCommandFill {

  final GraphicsGradient gradient;

  GraphicsCommandFillGradient(this.gradient);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillGradient(gradient);
  }
}
