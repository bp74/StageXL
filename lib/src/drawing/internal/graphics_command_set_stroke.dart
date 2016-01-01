part of stagexl.drawing.internal;

class GraphicsCommandSetStroke extends GraphicsCommand {

  final GraphicsStroke stroke;
  GraphicsCommandSetStroke(this.stroke);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.setStroke(stroke);
  }
}
