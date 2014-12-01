part of stagexl.drawing;

class _GraphicsCommandLineTo extends _GraphicsCommand {

  num _x, _y;

  _GraphicsCommandLineTo(num x, num y) {
    _x = x.toDouble();
    _y = y.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.lineTo(_x, _y);
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_x, _y);
    }

    bounds.updatePath(bounds.cursorX, bounds.cursorY);
    bounds.updatePath(_x, _y);
    bounds.updateCursor(_x, _y);
  }
}
