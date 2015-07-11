part of stagexl.drawing;

class _GraphicsCommandMoveTo extends GraphicsCommand {

  final double x;
  final double y;

  _GraphicsCommandMoveTo(num x, num y) :
    x = x.toDouble(),
    y = y.toDouble();

  @override
  void updateContext(GraphicsContext context) {
    context.moveTo(x, y);
  }


  /*
  @override
  void updateBounds(GraphicsBounds bounds) {
    bounds.updateCursor(x, y);
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.moveTo(x, y);
  }
  */
}
