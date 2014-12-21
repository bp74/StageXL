part of stagexl.drawing;

class _GraphicsCommandRect extends _GraphicsCommand {

  final double x;
  final double y;
  final double width;
  final double height;

  _GraphicsCommandRect(num x, num y, num width, num height) :
    x = x.toDouble(),
    y = y.toDouble(),
    width = width.toDouble(),
    height = height.toDouble();

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    bounds.updateCursor(x, y);
    bounds.updatePath(x, y);
    bounds.updatePath(x + width, y);
    bounds.updatePath(x + width, y + height);
    bounds.updatePath(x, y + height);
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.rect(x, y, width, height);
  }
}
