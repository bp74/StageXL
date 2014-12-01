part of stagexl.drawing;

class _GraphicsCommandMoveTo extends _GraphicsCommand {

  num _x, _y;

  _GraphicsCommandMoveTo(num x, num y) {
    _x = x.toDouble();
    _y = y.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.moveTo(_x, _y);
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.updateCursor(_x, _y);
  }
}
