part of stagexl.drawing;

class _GraphicsCommandMoveTo extends _GraphicsCommand {

  num _x, _y;

  _GraphicsCommandMoveTo(num x, num y) {
    _x = x.toDouble();
    _y = y.toDouble();
  }

  //---------------------------------------------------------------------------

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.updateCursor(_x, _y);
  }

  @override
  void render(CanvasRenderingContext2D context) {
    context.moveTo(_x, _y);
  }

}
