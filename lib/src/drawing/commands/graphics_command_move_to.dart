part of stagexl.drawing;

class _GraphicsCommandMoveTo extends _GraphicsCommand {

  final double x;
  final double y;

  _GraphicsCommandMoveTo(num x, num y) :
    x = x.toDouble(),
    y = y.toDouble();

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.updateCursor(x, y);
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.moveTo(x, y);
  }

}
