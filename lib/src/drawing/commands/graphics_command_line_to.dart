part of stagexl.drawing;

class _GraphicsCommandLineTo extends _GraphicsCommand {

  final double x;
  final double y;

  _GraphicsCommandLineTo(num x, num y) :
    x = x.toDouble(),
    y = y.toDouble();

  @override
  void updateBounds(_GraphicsBounds bounds) {

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

}
