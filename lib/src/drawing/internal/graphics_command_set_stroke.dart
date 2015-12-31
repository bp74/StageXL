part of stagexl.drawing.internal;

class GraphicsCommandSetStroke extends GraphicsCommand {

  final GraphicsPath stroke;
  GraphicsCommandSetStroke(this.stroke);

  //---------------------------------------------------------------------------

  @override
  void updateContext(GraphicsContext context) {
    context.setStroke(stroke);
  }
}
