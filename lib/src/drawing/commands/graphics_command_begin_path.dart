part of stagexl.drawing;

class _GraphicsCommandBeginPath extends _GraphicsCommand {

  _GraphicsCommandBeginPath();

  @override
  void updateBounds(_GraphicsBounds bounds) {
    bounds.resetPath();
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.beginPath();
  }
}
