part of stagexl.drawing;

class _GraphicsCommandLineTo extends GraphicsCommand {

  final double x;
  final double y;

  _GraphicsCommandLineTo(num x, num y) :
    x = x.toDouble(),
    y = y.toDouble();

  @override
  void updateContext(GraphicsContext context) {
    context.lineTo(x, y);
  }

  /*
  @override
  void updateBounds(GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(x, y);
    }

    bounds.updatePath(bounds.cursorX, bounds.cursorY);
    bounds.updatePath(x, y);
    bounds.updateCursor(x, y);
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.lineTo(x, y);
  }
  */
}
