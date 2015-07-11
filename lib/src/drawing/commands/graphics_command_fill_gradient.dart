part of stagexl.drawing;

class _GraphicsCommandFillGradient extends GraphicsCommand {

  final GraphicsGradient gradient;

  _GraphicsCommandFillGradient(this.gradient);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.fillGradient(gradient);
  }
}
