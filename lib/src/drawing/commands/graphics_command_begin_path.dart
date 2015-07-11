part of stagexl.drawing;

class _GraphicsCommandBeginPath extends GraphicsCommand {

  _GraphicsCommandBeginPath();

  @override
  void updateContext(GraphicsContext context) {
    context.beginPath();
  }

  /*
  @override
  void updateBounds(GraphicsBounds bounds) {
    bounds.resetPath();
  }

  @override
  void drawCanvas(CanvasRenderingContext2D context) {
    context.beginPath();
  }
  */
}
