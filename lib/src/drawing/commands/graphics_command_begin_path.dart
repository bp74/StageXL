part of stagexl.drawing;

class _GraphicsCommandBeginPath extends _GraphicsCommand {

  _GraphicsCommandBeginPath();

  render(CanvasRenderingContext2D context) {
    context.beginPath();
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.resetPath();
  }
}

