part of stagexl.drawing;

class _GraphicsCommandRect extends _GraphicsCommand {

  num _x, _y;
  num _width, _height;

  _GraphicsCommandRect(num x, num y, num width, num height) {
    _x = x.toDouble();
    _y = y.toDouble();
    _width = width.toDouble();
    _height = height.toDouble();
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {

    bounds.updateCursor(_x, _y);
    bounds.updatePath(_x, _y);
    bounds.updatePath(_x + _width, _y);
    bounds.updatePath(_x + _width, _y + _height);
    bounds.updatePath(_x, _y + _height);
  }

  @override
  void render(CanvasRenderingContext2D context) {
    context.rect(_x, _y, _width, _height);
  }
}